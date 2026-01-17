import '../../core/entities/user.dart';
import '../../core/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<User> login(String email, String password) {
    return remote.login(email, password);
  }

  @override
  Future<User> register(String email, String password) {
    return remote.register(email, password);
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }
}