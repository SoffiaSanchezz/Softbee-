import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reset_password_state.dart';

class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  ResetPasswordController() : super(const ResetPasswordState());

  void onPasswordChanged(String password) {
    state = state.copyWith(password: password, passwordChanged: false, clearErrorMessage: true);
  }

  void onConfirmPasswordChanged(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, passwordChanged: false, clearErrorMessage: true);
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleShowConfirmPassword() {
    state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nueva contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Debe contener al menos un carácter especial';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != state.password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<bool> submitNewPassword(String token) async {
    if (state.isLoading) return false;

    // Validar en el controlador antes de simular envío
    String? passwordError = validatePassword(state.password);
    String? confirmPasswordError = validateConfirmPassword(state.confirmPassword);

    if (passwordError != null || confirmPasswordError != null) {
      state = state.copyWith(errorMessage: passwordError ?? confirmPasswordError);
      return false;
    }

    state = state.copyWith(isLoading: true, passwordChanged: false, clearErrorMessage: true);

    // --- Simulación de Backend ---
    await Future.delayed(const Duration(seconds: 2));

    if (token == 'invalid_token') {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'El token de restablecimiento es inválido o ha expirado.',
      );
      return false;
    } else if (state.password.toLowerCase() == 'password123') { // Example of a weak password
       state = state.copyWith(
        isLoading: false,
        errorMessage: 'La nueva contraseña es demasiado débil. Intente otra.',
      );
      return false;
    } else {
      state = state.copyWith(
        isLoading: false,
        passwordChanged: true,
      );
      // Automatically navigate to login after success.
      // This is handled in the UI by a ref.listen, but a direct navigation might be needed for tests/specific flows
      // For now, let the UI handle the navigation as it has access to context.
      return true;
    }
  }

  void resetState() {
    state = const ResetPasswordState();
  }
}
