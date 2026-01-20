import '../../../../core/error/failures.dart';
import 'package:either_dart/either.dart';
import '../entities/apiary.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final List<Apiary> apiaries;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.apiaries,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      apiaries: params.apiaries,
    );
  }
}

