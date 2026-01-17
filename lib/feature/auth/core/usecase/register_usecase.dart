// core/usecases/register_usecase.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  RegisterParams(this.email, this.password);
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(RegisterParams params) {
    return repository.register(params.email, params.password);
  }
}
