import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/router/app_routes.dart';
import '../../core/usecase/login_usecase.dart';
import 'auth_providers.dart'; // To access authControllerProvider for actual login
import 'login_state.dart';
import '../controllers/auth_controller.dart'; // Import AuthController for AuthState

class LoginController extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;
  final AuthController _authController; // To update the global auth state

  LoginController(this._loginUseCase, this._authController) : super(const LoginState());

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

    // --- Backend interaction commented out as per request ---
    // The actual login logic would typically go here, calling the use case.
    // For now, we'll simulate a delay and a potential success/failure.

    // final result = await _loginUseCase(LoginParams(state.identifier, state.password));

    // result.fold(
    //   (failure) {
    //     state = state.copyWith(isLoading: false, errorMessage: _mapFailureToMessage(failure));
    //   },
    //   (token) async {
    //     // On successful login, the AuthController would handle saving the token and updating user state
    //     // For this request, we're just simulating success and then letting authControllerProvider handle it.
    //     // Simulate a successful login and then update global auth state
    //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    //     _authController.login(state.identifier, state.password); // This would trigger the real login in AuthController
    //   },
    // );
    // --- End of commented out backend interaction ---

    // Simulating success/failure for UI demonstration purposes
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // You can uncomment the following lines to simulate actual login via AuthController
    // This part bridges to the existing global AuthController.
    await _authController.login(state.identifier, state.password);

    // Check if login was successful through the global AuthController's state
    if (_authController.state.isAuthenticated) {
      state = state.copyWith(isLoading: false);
      // The router in main.dart should handle navigation based on authControllerProvider state
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _authController.state.error ?? 'Error en el inicio de sesión. Inténtalo de nuevo.',
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case AuthFailure:
        return (failure as AuthFailure).message;
      case InvalidInputFailure:
        return (failure as InvalidInputFailure).message;
      default:
        return 'Error inesperado. Por favor, inténtalo de nuevo.';
    }
  }
}
