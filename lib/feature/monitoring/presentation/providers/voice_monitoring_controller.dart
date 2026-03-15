import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'voice_monitoring_state.dart';
import '../../domain/entities/hive_question.dart';
import '../../domain/entities/hive_answer.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/repositories/answer_repository.dart';
import '../../../beehive/domain/repositories/beehive_repository.dart';
import '../../../beehive/domain/entities/beehive.dart';
import 'questions_providers.dart';
import '../../../beehive/presentation/providers/beehive_providers.dart';
import '../../../../core/services/offline_storage_service.dart';

final offlineStorageServiceProvider = Provider((ref) => OfflineStorageService());

final voiceMonitoringControllerProvider =
    StateNotifierProvider.autoDispose<VoiceMonitoringController, VoiceMonitoringState>((ref) {
  final questionRepo = ref.read(questionRepositoryProvider);
  final answerRepo = ref.read(answerRepositoryProvider);
  final beehiveRepo = ref.read(beehiveRepositoryProvider);
  final offlineStorage = ref.read(offlineStorageServiceProvider);
  return VoiceMonitoringController(
    questionRepo: questionRepo,
    answerRepo: answerRepo,
    beehiveRepo: beehiveRepo,
    offlineStorage: offlineStorage,
  );
});

class VoiceMonitoringController extends StateNotifier<VoiceMonitoringState> {
  final QuestionRepository questionRepo;
  final AnswerRepository answerRepo;
  final BeehiveRepository beehiveRepo;
  final OfflineStorageService offlineStorage;

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;
  bool _speechInitialized = false;
  bool _isProcessing = false; // PREVENIR DOBLE ACTIVACIÓN
  Timer? _listeningTimer;
  Timer? _ttsCompletionTimer;
  
  static const int _maxListenSeconds = 30;
  static const int _silenceTimeout = 8;

  VoiceMonitoringController({
    required this.questionRepo,
    required this.answerRepo,
    required this.beehiveRepo,
    required this.offlineStorage,
  }) : super(const VoiceMonitoringState()) {
    _speech = stt.SpeechToText();
    _audioPlayer = AudioPlayer();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("es-ES");
    // _flutterTts.setVoice({"name": "es-es-x-eed-network", "locale": "es-ES"});
    _flutterTts.setPitch(1.1);
    _flutterTts.setSpeechRate(0.45);
    
    // IMPORTANTE: Asegurar que se espere a que termine de hablar
    _flutterTts.awaitSpeakCompletion(true);
    
    _flutterTts.setCompletionHandler(() async {
      if (!mounted) return;
      debugPrint("🤖 Maya finished speaking");
      
      _ttsCompletionTimer?.cancel();
      _ttsCompletionTimer = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        
        if (state.step == MonitoringStep.greeting) {
          _goToSelectHive();
        } else if (state.step == MonitoringStep.selectHive || 
                   state.step == MonitoringStep.askingQuestions) {
          startListening();
        }
      });
    });

    _flutterTts.setErrorHandler((msg) async {
      debugPrint("🤖 Maya TTS Error: $msg");
      _isProcessing = false;
      if (mounted && state.step != MonitoringStep.finished && state.step != MonitoringStep.error) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) startListening();
        });
      }
    });
  }

  Future<void> playBeep() async {
    try {
      debugPrint("🎵 Maya Playing beep...");
      // Desactivado temporalmente por error de asset 404
      // await _audioPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
      debugPrint("🎵 Maya failed to play beep: $e");
    }
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_speechInitialized) return true;
    
    try {
      debugPrint("🎤 Maya initializing SpeechToText...");
      _speechInitialized = await _speech.initialize(
        onStatus: (val) {
          debugPrint("🎤 Maya Speech Status: $val");
          if (val == 'done' || val == 'notListening') {
            if (mounted) state = state.copyWith(isListening: false);
            _isProcessing = false;
          }
        },
        onError: (val) {
          debugPrint("🎤 Maya Speech Error: ${val.errorMsg}");
          if (mounted) {
            state = state.copyWith(isListening: false);
            _isProcessing = false;
            if (val.permanent) _speechInitialized = false;
          }
        },
        debugLogging: false,
      );
      return _speechInitialized;
    } catch (e) {
      debugPrint("🎤 Maya Speech Init Exception: $e");
      return false;
    }
  }

  Future<void> initMonitoring(String apiaryId) async {
    debugPrint("📋 Initializing monitoring for apiary: $apiaryId");
    if (mounted) state = state.copyWith(step: MonitoringStep.initial);
    
    final hivesResult = await beehiveRepo.getBeehivesByApiary(apiaryId);
    
    hivesResult.fold(
      (failure) {
        debugPrint("❌ Error loading hives: ${failure.message}");
        if (mounted) state = state.copyWith(step: MonitoringStep.error, errorMessage: failure.message);
      },
      (hives) {
        debugPrint("✅ Loaded ${hives.length} hives");
        if (mounted) {
          state = state.copyWith(availableHives: hives);
          _startFlow();
        }
      },
    );
  }

  void _startFlow() async {
    if (mounted) state = state.copyWith(step: MonitoringStep.greeting);
    await _speak("Hola apicultor. Vamos a realizar el monitoreo de la colmena.");
  }

  void _goToSelectHive() async {
    if (!mounted) return;
    state = state.copyWith(step: MonitoringStep.selectHive);
    String hiveNumbers = state.availableHives.map((h) => h.beehiveNumber.toString()).join(", ");
    await _speak("Por favor, dime el número de la colmena que quieres monitorear. Las disponibles son: $hiveNumbers");
  }

  Future<void> _speak(String text) async {
    try {
      debugPrint("🤖 Maya speaking: $text");
      if (_speech.isListening) {
        await _speech.stop();
        if (mounted) state = state.copyWith(isListening: false);
      }
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("🤖 Maya speech synthesis failed: $e");
    }
  }

  Future<void> startListening() async {
    if (!mounted) return;

    if (_isProcessing || state.isListening || _speech.isListening) {
      debugPrint("⚠️ Maya Mic already active, skipping...");
      return;
    }

    _isProcessing = true;

    // Comentamos protección kIsWeb temporalmente para pruebas
    /*
    if (!kIsWeb) {
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) state = state.copyWith(errorMessage: "Permiso de micrófono denegado");
          _isProcessing = false;
          return;
        }
      }
    }
    */

    final isReady = await _ensureSpeechInitialized();

    if (isReady && mounted) {
      debugPrint("🎤 Maya listening for response...");
      state = state.copyWith(isListening: true, lastRecognizedWords: "");
      
      _listeningTimer?.cancel();
      _listeningTimer = Timer(const Duration(seconds: _silenceTimeout), () {
        if (mounted && state.isListening && state.lastRecognizedWords.isEmpty) {
          debugPrint("🎤 Maya Mic timeout: No speech detected");
          _handleTimeout();
        }
      });

      await _speech.listen(
        onResult: (val) async {
          if (mounted) {
            if (val.recognizedWords.isNotEmpty) {
              state = state.copyWith(lastRecognizedWords: val.recognizedWords);
              _listeningTimer?.cancel();
            }

            if (val.finalResult) {
              debugPrint("👤 User said: ${val.recognizedWords}");
              await _speech.stop();
              state = state.copyWith(isListening: false);
              _isProcessing = false;
              _processVoiceInput(val.recognizedWords);
            }
          }
        },
        localeId: "es-ES",
        listenFor: const Duration(seconds: _maxListenSeconds),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
      );
    } else {
      _isProcessing = false;
    }
  }

  void _handleTimeout() async {
    stopListening();
    if (!mounted) return;
    if (state.step == MonitoringStep.selectHive) {
      await _speak("No te escuché. Por favor, dime el número de la colmena.");
    } else if (state.step == MonitoringStep.askingQuestions) {
      final question = state.questions[state.currentQuestionIndex];
      final questionText = question.apiaryQuestion?.texto ?? "No te escuché.";
      await _speak("No te escuché. Repito: $questionText");
    }
  }

  void _processVoiceInput(String input) async {
    if (input.trim().isEmpty) {
      _handleTimeout();
      return;
    }

    if (!mounted) return;
    
    if (state.step == MonitoringStep.selectHive) {
      _handleHiveSelection(input);
    } else if (state.step == MonitoringStep.askingQuestions) {
      _handleQuestionAnswer(input);
    }
  }

  void _handleHiveSelection(String input) async {
    String normalized = input.toLowerCase();
    debugPrint("🔍 Maya processing hive selection: $normalized");
    
    int? hiveNumber = _extractNumber(normalized);

    if (hiveNumber != null) {
      final hive = state.availableHives.firstWhere(
        (h) => h.beehiveNumber == hiveNumber,
        orElse: () => const Beehive(id: '', apiaryId: ''),
      );

      if (hive.id.isNotEmpty) {
        debugPrint("✅ Hive selected: $hiveNumber");
        state = state.copyWith(selectedHive: hive, step: MonitoringStep.loadingQuestions);
        await _speak("Colmena $hiveNumber seleccionada.");
        _loadQuestions(hive.id);
      } else {
        debugPrint("⚠️ Hive $hiveNumber not found in available list");
        await _speak("No encontré la colmena número $hiveNumber en este apiario. Intenta con otra.");
      }
    } else {
      debugPrint("⚠️ Could not parse hive number from: $input");
      await _speak("No entendí el número. Por favor, dime el número de la colmena.");
    }
  }

  int? _extractNumber(String text) {
    final wordToNum = {
      "uno": 1, "una": 1, "primer": 1, "primera": 1, "1": 1,
      "dos": 2, "2": 2, "segunda": 2,
      "tres": 3, "3": 3, "tercera": 3,
      "cuatro": 4, "4": 4, "cuarta": 4,
      "cinco": 5, "5": 5, "quinta": 5,
      "seis": 6, "6": 6, "siete": 7, "7": 7,
      "ocho": 8, "8": 8, "nueve": 9, "9": 9, "diez": 10, "10": 10
    };

    for (var entry in wordToNum.entries) {
      if (text.contains(entry.key)) return entry.value;
    }

    final match = RegExp(r'\d+').firstMatch(text);
    if (match != null) return int.parse(match.group(0)!);
    
    return null;
  }

  void _loadQuestions(String hiveId) async {
    debugPrint("📋 Loading questions for hive $hiveId...");
    final questionsResult = await questionRepo.getHiveQuestions(hiveId);
    
    questionsResult.fold(
      (failure) {
        debugPrint("❌ Error loading questions: ${failure.message}");
        if (mounted) state = state.copyWith(step: MonitoringStep.error, errorMessage: failure.message);
      },
      (questions) {
        debugPrint("✅ Loaded ${questions.length} questions");
        if (mounted) {
          if (questions.isEmpty) {
            state = state.copyWith(step: MonitoringStep.finished);
            _speak("No hay preguntas configuradas para esta colmena. Monitoreo finalizado.");
          } else {
            state = state.copyWith(
              questions: questions,
              currentQuestionIndex: 0,
              step: MonitoringStep.askingQuestions,
              answers: {},
            );
            // Pequeña pausa para que termine de hablar el mensaje de selección
            Future.delayed(const Duration(milliseconds: 800), _askCurrentQuestion);
          }
        }
      },
    );
  }

  void _askCurrentQuestion() async {
    if (!mounted) return;
    if (state.currentQuestionIndex >= state.questions.length) {
      _saveAllAnswers();
      return;
    }

    final question = state.questions[state.currentQuestionIndex];
    final total = state.questions.length;
    final index = state.currentQuestionIndex;
    
    String prefix = "Pregunta ${index + 1} de $total: ";
    final questionText = question.apiaryQuestion?.texto ?? "Siguiente pregunta";
    
    debugPrint("➡️ Next question: ${index + 1} of $total");
    await _speak("$prefix $questionText");
  }

  void _handleQuestionAnswer(String input) async {
    if (!mounted) return;
    
    final index = state.currentQuestionIndex;
    final question = state.questions[index];
    final questionText = question.apiaryQuestion?.texto ?? "pregunta";
    
    debugPrint("✅ Answer recorded: $questionText -> $input");
    
    final updatedAnswers = Map<String, String>.from(state.answers);
    updatedAnswers[question.id] = input;
    
    state = state.copyWith(answers: updatedAnswers);

    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      // Breve pausa antes de la siguiente pregunta
      Future.delayed(const Duration(milliseconds: 600), _askCurrentQuestion);
    } else {
      debugPrint("✅ All questions answered. Saving...");
      _saveAllAnswers();
    }
  }

  void _saveAllAnswers() async {
    if (!mounted) return;
    state = state.copyWith(step: MonitoringStep.saving);
    await _speak("Guardando las ${state.answers.length} respuestas en el sistema.");

    final List<HiveAnswer> answersToSave = state.answers.entries.map((e) {
      return HiveAnswer(
        id: '',
        hiveQuestionId: e.key,
        answer: e.value,
      );
    }).toList();

    final result = await answerRepo.createAnswersBatch(answersToSave);

    result.fold(
      (failure) async {
        debugPrint("💾 Maya error saving batch: ${failure.message}");
        // Intentar guardado offline
        try {
          await offlineStorage.saveAnswersLocally({
            'hive_id': state.selectedHive?.id,
            'apiary_id': state.selectedHive?.apiaryId,
            'date': DateTime.now().toIso8601String(),
            'answers': answersToSave.map((a) => a.toJson()).toList(),
          });
          if (mounted) state = state.copyWith(step: MonitoringStep.finished, isOffline: true);
          await _speak("Guardado localmente por falta de conexión. Monitoreo finalizado.");
        } catch (e) {
          debugPrint("💾 Error fatal guardando localmente: $e");
          if (mounted) state = state.copyWith(step: MonitoringStep.error, errorMessage: "Error guardando datos");
        }
      },
      (savedAnswers) async {
        debugPrint("💾 Saved ${savedAnswers.length} answers successfully");
        if (mounted) state = state.copyWith(step: MonitoringStep.finished);
        await _speak("Monitoreo completado con éxito. Muchas gracias apicultor.");
      },
    );
  }

  Future<void> syncOfflineData() async {
    try {
      final offlineData = await offlineStorage.getOfflineAnswers();
      if (offlineData.isEmpty) return;

      debugPrint("🔄 Maya syncing offline data...");
      for (var data in offlineData) {
        final List<dynamic> answersJson = data['answers'];
        final List<HiveAnswer> answers = answersJson.map((j) => HiveAnswer.fromJson(j)).toList();
        await answerRepo.createAnswersBatch(answers);
      }
      
      await offlineStorage.clearOfflineAnswers();
      debugPrint("✅ Offline data synced successfully");
    } catch (e) {
      debugPrint("🔄 Error syncing offline data: $e");
    }
  }

  void stopListening() {
    debugPrint("🎤 Maya forcing Mic stop");
    _speech.stop();
    _isProcessing = false;
    if (mounted) state = state.copyWith(isListening: false);
  }

  @override
  void dispose() {
    debugPrint("👋 Maya VoiceMonitoringController Disposing...");
    _listeningTimer?.cancel();
    _ttsCompletionTimer?.cancel();
    _flutterTts.stop();
    _speech.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}
