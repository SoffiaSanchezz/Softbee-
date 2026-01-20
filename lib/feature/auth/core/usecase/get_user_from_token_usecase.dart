import 'package:either_dart/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetUserFromTokenUseCase implements UseCase<User, String> {
  final AuthRepository repository;

  GetUserFromTokenUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String params) async {
    return repository.getUserFromToken(params);
  }
}
