import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_monitoring_state.dart';
import '../../domain/entities/hive_answer.dart';
import '../../domain/entities/hive_question.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/repositories/answer_repository.dart';
import '../../../beehive/domain/repositories/beehive_repository.dart';
import '../../../beehive/domain/entities/beehive.dart';
import '../../../../core/services/offline_storage_service.dart';
import 'questions_providers.dart';
import '../../../beehive/presentation/providers/beehive_providers.dart';
import '../../../maya/domain/repositories/maya_repository.dart';
import '../../../maya/presentation/providers/maya_providers.dart';
import '../../domain/entities/question_model.dart';

final offlineStorageServiceProvider = Provider((ref) => OfflineStorageService());

final voiceMonitoringControllerProvider =
    StateNotifierProvider<VoiceMonitoringController, VoiceMonitoringState>((ref) {
  final questionRepo = ref.read(questionRepositoryProvider);
  final answerRepo = ref.read(answerRepositoryProvider);
  final beehiveRepo = ref.read(beehiveRepositoryProvider);
  final mayaRepo = ref.read(mayaRepositoryProvider); // Added MayaRepo
  final offlineStorage = ref.read(offlineStorageServiceProvider);
  return VoiceMonitoringController(
    questionRepo: questionRepo,
    answerRepo: answerRepo,
    beehiveRepo: beehiveRepo,
    mayaRepo: mayaRepo,
    offlineStorage: offlineStorage,
  );
});

class VoiceMonitoringController extends StateNotifier<VoiceMonitoringState> {
  final QuestionRepository questionRepo;
  final AnswerRepository answerRepo;
  final BeehiveRepository beehiveRepo;
  final MayaRepository mayaRepo; // Added MayaRepo
  final OfflineStorageService offlineStorage;

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _speechInitialized = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _isDisposed = false; // Flag to prevent ref.read after dispose
  Timer? _listeningTimer;
  Timer? _ttsCompletionTimer;
  int _retryCount = 0;

  static const int _silenceTimeout = 7;
  static const int _maxRetries = 2;

  VoiceMonitoringController({
    required this.questionRepo,
    required this.answerRepo,
    required this.beehiveRepo,
    required this.mayaRepo,
    required this.offlineStorage,
  }) : super(const VoiceMonitoringState()) {
    _speech = stt.SpeechToText();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("es-ES");
    _flutterTts.setPitch(1.1);
    _flutterTts.setSpeechRate(0.45);
    _flutterTts.awaitSpeakCompletion(true);
    
    _flutterTts.setCompletionHandler(() {
      if (_isDisposed) return;
      _isSpeaking = false;
      _onTtsFinished();
    });

    _flutterTts.setErrorHandler((msg) {
      if (_isDisposed) return;
      _isSpeaking = false;
      _onTtsFinished();
    });
  }

  void _onTtsFinished() {
    _ttsCompletionTimer?.cancel();
    _ttsCompletionTimer = Timer(const Duration(milliseconds: 800), () {
      if (_isDisposed) return;
      if (state.step == MonitoringStep.greeting) {
        _goToSelectHive();
      } else if (state.step == MonitoringStep.selectHive || 
                 state.step == MonitoringStep.askingQuestions ||
                 state.step == MonitoringStep.askContinuation) {
        startListening();
      }
    });
  }

  Future<void> initMonitoring(String apiaryId) async {
    if (_isDisposed) return;
    state = state.copyWith(step: MonitoringStep.initial, errorMessage: null);
    
    final hivesResult = await beehiveRepo.getBeehivesByApiary(apiaryId);
    hivesResult.fold(
      (failure) {
        if (!_isDisposed) state = state.copyWith(step: MonitoringStep.error, errorMessage: failure.message);
      },
      (hives) {
        if (!_isDisposed) {
          state = state.copyWith(availableHives: hives);
          _startFlow();
        }
      },
    );
  }

  void _startFlow() async {
    if (_isDisposed) return;
    state = state.copyWith(step: MonitoringStep.greeting);
    await _speak("Hola apicultor. Vamos a realizar el monitoreo de tus colmenas.");
  }

  void _goToSelectHive() async {
    if (_isDisposed) return;
    state = state.copyWith(step: MonitoringStep.selectHive);
    String hiveNumbers = state.availableHives.map((h) => h.beehiveNumber.toString()).join(", ");
    await _speak("Por favor dime el número de la colmena que quieres monitorear. Las disponibles son: $hiveNumbers.");
  }

  Future<void> _speak(String text) async {
    if (_isDisposed) return;
    try {
      _isSpeaking = true;
      if (_speech.isListening) {
        await _speech.stop();
        state = state.copyWith(isListening: false);
      }
      _isProcessing = false;
      await _flutterTts.speak(text);
      
      // Watchdog timer for TTS completion in case OS callback fails
      _ttsCompletionTimer?.cancel();
      _ttsCompletionTimer = Timer(Duration(milliseconds: (text.length * 90).clamp(3000, 15000)), () {
        if (!_isDisposed && _isSpeaking) {
          _isSpeaking = false;
          _onTtsFinished();
        }
      });
    } catch (e) {
      _isSpeaking = false;
    }
  }

  Future<void> startListening() async {
    if (_isDisposed || _isSpeaking || _isProcessing || state.isListening) return;

    _isProcessing = true;
    if (!_speechInitialized) {
      _speechInitialized = await _speech.initialize(
        onStatus: (val) {
          if (!_isDisposed && (val == 'done' || val == 'notListening')) {
            state = state.copyWith(isListening: false);
            _isProcessing = false;
          }
        },
        onError: (val) {
          if (!_isDisposed) {
            state = state.copyWith(isListening: false);
            _isProcessing = false;
          }
        },
      );
    }

    if (_speechInitialized && !_isDisposed) {
      state = state.copyWith(isListening: true, lastRecognizedWords: "");
      _listeningTimer?.cancel();
      _listeningTimer = Timer(const Duration(seconds: _silenceTimeout), () {
        if (!_isDisposed && state.isListening && state.lastRecognizedWords.isEmpty) {
          _handleTimeout();
        }
      });

      await _speech.listen(
        onResult: (val) {
          if (!_isDisposed) {
            state = state.copyWith(lastRecognizedWords: val.recognizedWords);
            if (val.finalResult) {
              _isProcessing = false;
              _processVoiceInput(val.recognizedWords);
            }
          }
        },
        localeId: "es-ES",
      );
    } else {
      _isProcessing = false;
    }
  }

  void _handleTimeout() async {
    if (_isDisposed) return;
    stopListening();
    _retryCount++;
    if (_retryCount > _maxRetries) {
      _retryCount = 0;
      await _speak("Finalizaremos el monitoreo por falta de respuesta.");
      state = state.copyWith(step: MonitoringStep.finished);
      return;
    }
    _speak("No te escuché bien. Por favor repite.");
  }

  void _processVoiceInput(String input) async {
    if (input.trim().isEmpty) {
      _handleTimeout();
      return;
    }
    if (_isDisposed) return;
    _retryCount = 0;
    if (state.step == MonitoringStep.selectHive) {
      _handleHiveSelection(input);
    } else if (state.step == MonitoringStep.askingQuestions) {
      _handleQuestionAnswer(input);
    } else if (state.step == MonitoringStep.askContinuation) {
      _handleContinuationSelection(input);
    }
  }

  void _handleHiveSelection(String input) async {
    int? hiveNumber = _extractNumber(input.toLowerCase());
    if (hiveNumber != null) {
      final hive = state.availableHives.firstWhere(
        (h) => h.beehiveNumber == hiveNumber,
        orElse: () => const Beehive(id: '', apiaryId: ''),
      );
      if (hive.id.isNotEmpty) {
        state = state.copyWith(selectedHive: hive, step: MonitoringStep.loadingQuestions);
        await _speak("Colmena $hiveNumber seleccionada.");
        _iniciarMonitoreoDinamico(hive.id);
      } else {
        await _speak("No encontré la colmena $hiveNumber. Por favor dime otro número.");
      }
    } else {
      await _speak("Dime el número de la colmena.");
    }
  }

  void _iniciarMonitoreoDinamico(String hiveId) async {
    final result = await mayaRepo.iniciarMonitoreoVoz(hiveId);
    result.fold(
      (failure) {
        if (!_isDisposed) state = state.copyWith(step: MonitoringStep.error, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> pList = data['preguntas'];
        final List<HiveQuestion> questions = pList.map((p) => HiveQuestion(
          id: p['id'],
          hiveId: hiveId,
          apiaryQuestionId: '', // Not strictly needed for the flow
          displayOrder: 0,
          isActive: true,
          apiaryQuestion: Pregunta(
            id: p['id'],
            apiarioId: '',
            texto: p['texto'],
            tipoRespuesta: p['tipo'],
            obligatoria: p['obligatoria'] ?? false,
            orden: 0,
            opciones: p['opciones'] != null ? List<String>.from(p['opciones']) : null,
            min: p['min'],
            max: p['max'],
          )
        )).toList();

        if (!_isDisposed) {
          if (questions.isEmpty) {
            _speak("Sin preguntas configuradas. ¿Otra colmena?");
            state = state.copyWith(step: MonitoringStep.askContinuation);
          } else {
            state = state.copyWith(
              questions: questions,
              currentQuestionIndex: 0,
              step: MonitoringStep.askingQuestions,
              answers: {},
            );
            _askCurrentQuestion();
          }
        }
      },
    );
  }

  void _askCurrentQuestion() async {
    if (_isDisposed) return;
    if (state.currentQuestionIndex >= state.questions.length) {
      _saveAllAnswers();
      return;
    }
    
    final question = state.questions[state.currentQuestionIndex];
    final q = question.apiaryQuestion!;
    String textoVoz = q.texto;
    
    // Incluir instrucciones dinámicas según tipo
    if (q.tipoRespuesta == 'opciones' && q.opciones != null) {
      final opcionesTexto = q.opciones!.asMap().entries.map((e) => 
        "Opción ${e.key + 1}: ${e.value}"
      ).join('. ');
      textoVoz += '. Las opciones son: $opcionesTexto. Di el número de la opción.';
    } else if (q.tipoRespuesta == 'numero') {
      textoVoz += '. Di un número entre ${q.min} y ${q.max}.';
    }
    
    await _speak(textoVoz);
  }

  void _handleQuestionAnswer(String input) async {
    if (_isDisposed) return;
    final question = state.questions[state.currentQuestionIndex];
    final q = question.apiaryQuestion!;
    String valorProcesado = input;
    
    // Procesar según tipo: Si es opción, permitir decir el número
    if (q.tipoRespuesta == 'opciones' && q.opciones != null) {
      final numero = _extractNumber(input);
      if (numero != null && numero > 0 && numero <= q.opciones!.length) {
        valorProcesado = q.opciones![numero - 1];
      }
    } else if (q.tipoRespuesta == 'numero') {
      final numero = _extractNumber(input);
      if (numero != null) {
        valorProcesado = numero.toString();
      }
    }
    
    final updatedAnswers = Map<String, String>.from(state.answers)..[question.id] = valorProcesado;
    state = state.copyWith(answers: updatedAnswers);
    
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      _askCurrentQuestion();
    } else {
      _saveAllAnswers();
    }
  }

  void _handleContinuationSelection(String input) async {
    final normalized = input.toLowerCase();
    if (normalized.contains("sí") || normalized.contains("si") || normalized.contains("otra")) {
      state = state.copyWith(selectedHive: null, questions: [], currentQuestionIndex: 0, answers: {}, step: MonitoringStep.selectHive);
      _goToSelectHive();
    } else {
      await _speak("Monitoreo finalizado. Hasta pronto.");
      state = state.copyWith(step: MonitoringStep.finished);
    }
  }

  void _saveAllAnswers() async {
    if (_isDisposed) return;
    state = state.copyWith(step: MonitoringStep.saving);
    await _speak("Guardando resultados.");
    
    final respuestas = state.answers.entries.map((e) => {
      'pregunta_id': e.key,
      'valor': e.value,
    }).toList();

    final result = await mayaRepo.guardarRespuestasVoz(state.selectedHive!.id, respuestas);
    
    result.fold(
      (failure) async {
        // Caching offline en caso de error
        await offlineStorage.saveAnswersLocally({
          'hive_id': state.selectedHive?.id,
          'respuestas': respuestas,
          'timestamp': DateTime.now().toIso8601String(),
        });
        if (!_isDisposed) {
          state = state.copyWith(step: MonitoringStep.askContinuation, isOffline: true);
          await _speak("Error de conexión. Lo guardé en el teléfono. ¿Otra colmena?");
        }
      },
      (success) async {
        if (!_isDisposed) {
          state = state.copyWith(step: MonitoringStep.askContinuation);
          await _speak("Guardado con éxito. ¿Otra colmena?");
        }
      },
    );
  }

  int? _extractNumber(String text) {
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(text);
    if (match != null) return int.tryParse(match.group(0)!);
    final Map<String, int> words = {
      'uno': 1, 'una': 1, 'primera': 1,
      'dos': 2, 'segunda': 2,
      'tres': 3, 'tercera': 3,
      'cuatro': 4, 'cuarta': 4,
      'cinco': 5, 'quinta': 5,
      'seis': 6, 'sexta': 6,
      'siete': 7, 'séptima': 7,
      'ocho': 8, 'octava': 8,
      'nueve': 9, 'novena': 9,
      'diez': 10, 'décima': 10
    };
    for (var entry in words.entries) {
      if (text.toLowerCase().contains(entry.key)) return entry.value;
    }
    return null;
  }

  Future<void> syncOfflineData() async {
    try {
      final offlineData = await offlineStorage.getOfflineAnswers();
      if (offlineData.isEmpty) return;
      for (var data in offlineData) {
        final hiveId = data['hive_id'];
        final List<Map<String, dynamic>> respuestas = List<Map<String, dynamic>>.from(data['respuestas']);
        await mayaRepo.guardarRespuestasVoz(hiveId, respuestas);
      }
      await offlineStorage.clearOfflineAnswers();
    } catch (_) {}
  }

  void stopListening() {
    _speech.stop();
    if (!_isDisposed) state = state.copyWith(isListening: false);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _listeningTimer?.cancel();
    _ttsCompletionTimer?.cancel();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }
}
