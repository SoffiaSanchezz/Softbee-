import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../providers/voice_monitoring_controller.dart';
import '../providers/voice_monitoring_state.dart';

class MayaVoicePage extends ConsumerStatefulWidget {
  final String apiaryId;
  const MayaVoicePage({super.key, required this.apiaryId});

  @override
  ConsumerState<MayaVoicePage> createState() => _MayaVoicePageState();
}

class _MayaVoicePageState extends ConsumerState<MayaVoicePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceMonitoringControllerProvider.notifier).initMonitoring(widget.apiaryId);
      // Attempt to sync offline data if any
      ref.read(voiceMonitoringControllerProvider.notifier).syncOfflineData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceMonitoringControllerProvider);
    final controller = ref.read(voiceMonitoringControllerProvider.notifier);

    // Dynamic message based on step
    String getStatusMessage() {
      if (state.step == MonitoringStep.error) return "Error: ${state.errorMessage}";
      if (state.step == MonitoringStep.finished) return "Monitoreo finalizado";
      if (state.isListening) return "Te escucho...";
      if (state.step == MonitoringStep.loadingQuestions) return "Cargando preguntas...";
      if (state.step == MonitoringStep.saving) return "Guardando...";
      return "Maya está lista";
    }

    String getCurrentPrompt() {
      if (state.step == MonitoringStep.greeting) return "Iniciando monitoreo...";
      if (state.step == MonitoringStep.selectHive) return "¿Qué colmena vamos a revisar?";
      if (state.step == MonitoringStep.loadingQuestions) return "Buscando configuración...";
      if (state.step == MonitoringStep.askingQuestions) {
        if (state.questions.isEmpty) return "";
        final q = state.questions[state.currentQuestionIndex];
        return q.apiaryQuestion?.texto ?? "";
      }
      if (state.step == MonitoringStep.finished) return "¡Todo listo!";
      return "";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBC209),
        elevation: 0,
        title: Text(
          'Maya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación Central
                _buildCentralAnimation(state.isListening),

                const SizedBox(height: 40),

                // Pregunta de Maya
                if (getCurrentPrompt().isNotEmpty)
                  _buildTextBubble(getCurrentPrompt(), isUser: false),

                const SizedBox(height: 20),

                // Texto reconocido (Lo que dice el usuario)
                if (state.lastRecognizedWords.isNotEmpty)
                  _buildTextBubble(state.lastRecognizedWords, isUser: true),

                const SizedBox(height: 40),

                // Instrucción / Estado
                Text(
                  getStatusMessage(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: state.step == MonitoringStep.error
                        ? Colors.red
                        : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de Micrófono / Acción Final
                if (state.step == MonitoringStep.finished)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Volver al Apiario"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBC209),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ).animate().scale()
                else
                  _buildMicButton(state.isListening, () {
                    if (state.isListening) {
                      controller.stopListening();
                    } else {
                      controller.startListening();
                    }
                  }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCentralAnimation(bool isListening) {
    if (isListening) {
      return Lottie.asset(
        'assets/animations/loader.json',
        width: 200,
        height: 200,
      );
    }
    
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBC209).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 80,
          color: const Color(0xFFFBC209),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
      ),
    );
  }

  Widget _buildTextBubble(String text, {required bool isUser}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFFBC209) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: isUser ? Colors.white : Colors.black87,
          fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildMicButton(bool isListening, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isListening ? Colors.red : const Color(0xFFFBC209),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? Colors.red : const Color(0xFFFBC209)).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 40,
        ),
      ).animate(target: isListening ? 1 : 0)
       .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 300.ms, curve: Curves.easeInOut),
    );
  }
}
