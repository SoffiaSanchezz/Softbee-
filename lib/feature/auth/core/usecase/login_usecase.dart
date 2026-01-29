import 'package:either_dart/either.dart';
import '../../../../core/error/failures.dart'; // Import Failure
// import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, String>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}