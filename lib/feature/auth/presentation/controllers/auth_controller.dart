import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../core/entities/user.dart';
import '../../core/usecase/check_auth_status_usecase.dart';
import '../../core/usecase/get_user_from_token_usecase.dart';
import '../../core/usecase/login_usecase.dart';
import '../../core/usecase/logout_usecase.dart';
import '../../core/usecase/register_usecase.dart';
// import '../../data/datasources/auth_local_datasource.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isRegistered;
  final bool isAuthenticating; // For initial auth check
  final String? token;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isRegistered = false,
    this.isAuthenticating = true,
    this.token,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isRegistered,
    bool? isAuthenticating,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isRegistered: isRegistered ?? this.isRegistered,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      token: token ?? this.token,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetUserFromTokenUseCase getUserFromTokenUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getUserFromTokenUseCase,
  }) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isAuthenticating: true);
    final result = await checkAuthStatusUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isAuthenticating: false,
          user: null,
          error: _mapFailureToMessage(failure),
        );
      },
      (user) {
        state = state.copyWith(isAuthenticating: false, user: user);
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final loginResult = await loginUseCase(LoginParams(email, password));

    await loginResult.fold(
      (failure) async {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (token) async {
        final userResult = await getUserFromTokenUseCase(token);
        userResult.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              user: null,
              error: _mapFailureToMessage(failure),
            );
          },
          (user) {
            state = state.copyWith(isLoading: false, user: user, token: token);
          },
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (_) {
        state = const AuthState(isAuthenticating: false); // Reset state completely
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case AuthFailure:
        return (failure as AuthFailure).message;
      case InvalidInputFailure:
        return (failure as InvalidInputFailure).message;
      default:
        return 'An unexpected error occurred.';
    }
  }

  void resetRegisterStatus() {
    state = state.copyWith(isRegistered: false);
  }
}

