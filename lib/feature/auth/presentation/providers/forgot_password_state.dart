import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  final bool isLoading;
  final bool emailSent;
  final String? errorMessage;
  final String email;
  final DateTime? lastSentTime;

  const ForgotPasswordState({
    this.isLoading = false,
    this.emailSent = false,
    this.errorMessage,
    this.email = '',
    this.lastSentTime,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? emailSent,
    String? errorMessage,
    String? email,
    DateTime? lastSentTime,
    bool clearErrorMessage = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      emailSent: emailSent ?? this.emailSent,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      lastSentTime: lastSentTime ?? this.lastSentTime,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    emailSent,
    errorMessage,
    email,
    lastSentTime,
  ];
}
