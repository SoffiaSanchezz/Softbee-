import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/user.dart';
import '../../core/usecase/login_usecase.dart';
import '../../core/usecase/register_usecase.dart';
import '../../core/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;
}


class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await loginUseCase(LoginParams(email, password));
      state = AuthState(user: user);
    } catch (e) {
      state = const AuthState(error: 'Login failed');
    }
  }

  Future<void> register(String email, String password) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await registerUseCase(RegisterParams(email, password));
      state = AuthState(user: user);
    } catch (e) {
      state = const AuthState(error: 'Register failed');
    }
  }

  void logout() {
    state = const AuthState();
  }
}


final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
  );
});
