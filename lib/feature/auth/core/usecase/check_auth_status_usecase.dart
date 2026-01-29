import 'package:either_dart/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return repository.checkAuthStatus();
  }
}
