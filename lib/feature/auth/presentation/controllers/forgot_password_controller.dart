import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forgot_password_state.dart';

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController() : super(const ForgotPasswordState());

  void onEmailChanged(String email) {
    state = state.copyWith(
      email: email,
      emailSent: false,
      clearErrorMessage: true,
    );
  }

  Future<void> resetPassword() async {
    if (state.isLoading) return;

    // Validar email
    if (!_isValidEmail(state.email)) {
      state = state.copyWith(
        errorMessage: 'Por favor, ingrese un correo electrónico válido.',
      );
      return;
    }

    // Prevenir spam
    if (state.lastSentTime != null &&
        DateTime.now().difference(state.lastSentTime!) <
            const Duration(minutes: 1)) {
      final remainingTime =
          60 - DateTime.now().difference(state.lastSentTime!).inSeconds;
      state = state.copyWith(
        errorMessage: 'Espere $remainingTime segundos para reenviar el correo.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      emailSent: false,
      clearErrorMessage: true,
    );

    // --- Simulación de Backend ---
    await Future.delayed(const Duration(seconds: 2));

    if (state.email.toLowerCase() == 'fail@example.com') {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Este correo electrónico no está registrado en nuestro sistema.',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        emailSent: true,
        lastSentTime: DateTime.now(),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void resetState() {
    state = const ForgotPasswordState();
  }
}
