import 'package:either_dart/either.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String
  name; // Campo que se usa solo en la UI para display o generación de username
  final String username;
  final String email;
  final String phone;
  final String password;

  RegisterParams({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class RegisterUseCase implements UseCase<Map<String, dynamic>, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    RegisterParams params,
  ) async {
    return await repository.registerUser(
      params.username,
      params.email,
      params.phone,
      params.password,
    );
  }
}
