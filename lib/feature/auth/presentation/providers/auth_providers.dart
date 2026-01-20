import 'package:Softbee/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/auth_repository.dart';
// import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/usecase/check_auth_status_usecase.dart';
import '../../core/usecase/get_user_from_token_usecase.dart';
import '../../core/usecase/login_usecase.dart';
import '../../core/usecase/logout_usecase.dart';
import '../../core/usecase/register_usecase.dart';
import '../controllers/auth_controller.dart';
import 'login_controller.dart'; // Import the new login controller
import 'login_state.dart'; // Import the new login state

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.read(authRepositoryProvider));
});

final getUserFromTokenUseCaseProvider = Provider<GetUserFromTokenUseCase>((ref) {
  return GetUserFromTokenUseCase(ref.read(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    checkAuthStatusUseCase: ref.read(checkAuthStatusUseCaseProvider),
    getUserFromTokenUseCase: ref.read(getUserFromTokenUseCaseProvider),
  );
});

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final authController = ref.watch(authControllerProvider.notifier); // Get notifier for actions
  return LoginController(loginUseCase, authController);
});

