import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_state.dart';
import '../controllers/auth_controller.dart'; // Import AuthController for AuthState

class LoginController extends StateNotifier<LoginState> {
  final AuthController _authController; // To update the global auth state

  LoginController(this._authController) : super(const LoginState());

  void onIdentifierChanged(String value) {
    state = state.copyWith(identifier: value, errorMessage: null);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<void> login() async {
    state = state.copyWith(isLoading: true, errorMessage: null, showValidationErrors: true);

    if (!state.isFormValid) {
      state = state.copyWith(isLoading: false, errorMessage: 'Por favor, complete todos los campos requeridos correctamente.');
      return;
    }

    // Add email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.identifier)) {
      state = state.copyWith(isLoading: false, errorMessage: 'Por favor, ingrese un formato de correo electrónico válido.');
      return;
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2)); 

    // This part bridges to the existing global AuthController.
    // The AuthController itself handles its state and uses the provided use cases.
    await _authController.login(state.identifier, state.password);

    // Check if the AuthController is still active and if login was successful
    // We access _authController.state here, which is guaranteed to be valid if _authController itself is not disposed.
    // The main issue of "Tried to use LoginController after `dispose` was called" typically happens when trying to access
    // `state` of *this* LoginController directly after it's disposed.
    // The previous implementation was accessing `state` directly inside the fold() callbacks,
    // where `this` LoginController might have already been disposed.
    // By awaiting `_authController.login` first and then checking its state, we avoid directly
    // updating `this.state` from a callback of `_loginUseCase` that might finish later.

    if (mounted) { // Explicitly checking mounted for the LoginController's state update.
      if (_authController.state.isAuthenticated) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _authController.state.error ?? 'Error en el inicio de sesión. Inténtalo de nuevo.',
        );
      }
    }
  }

  // To check if the controller is mounted, we need to add a private field.
  // This is a common pattern for StateNotifiers that interact with async operations.
  bool get mounted => hasListeners; // A proxy for mounted state in StateNotifier


}
