import 'package:equatable/equatable.dart';

class ResetPasswordState extends Equatable {
  final bool isLoading;
  final bool passwordChanged;
  final bool showPassword;
  final bool showConfirmPassword;
  final String? errorMessage;
  final String password;
  final String confirmPassword;

  const ResetPasswordState({
    this.isLoading = false,
    this.passwordChanged = false,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.errorMessage,
    this.password = '',
    this.confirmPassword = '',
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? passwordChanged,
    bool? showPassword,
    bool? showConfirmPassword,
    String? errorMessage,
    String? password,
    String? confirmPassword,
    bool clearErrorMessage = false,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    passwordChanged,
    showPassword,
    showConfirmPassword,
    errorMessage,
    password,
    confirmPassword,
  ];
}
