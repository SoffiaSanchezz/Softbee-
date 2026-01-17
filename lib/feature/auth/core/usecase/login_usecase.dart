import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}