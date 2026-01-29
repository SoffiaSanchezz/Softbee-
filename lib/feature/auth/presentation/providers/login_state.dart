import 'package:flutter/material.dart'; // Import for Color

class LoginState {
  final String identifier;
  final String password;
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final bool showValidationErrors;

  const LoginState({
    this.identifier = '',
    this.password = '',
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.showValidationErrors = false,
  });

  bool get isFormValid {
    // Add validation logic here
    return identifier.isNotEmpty && password.length >= 8;
  }

  LoginState copyWith({
    String? identifier,
    String? password,
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    bool? showValidationErrors,
  }) {
    return LoginState(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage, // Nullify if not provided to clear previous errors
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }
}

// Color constants for easier access and consistency
class AppColors {
  static const Color primaryYellow = Color(0xFFFFD100);
  static const Color accentYellow = Color(0xFFFFAB00);
  static const Color lightYellow = Color(0xFFFFF8E1);
  static const Color darkYellow = Color(0xFFF9A825);
  static const Color textDark = Color(0xFF333333);
}
