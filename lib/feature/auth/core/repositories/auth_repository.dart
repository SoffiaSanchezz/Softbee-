import 'package:either_dart/either.dart';

import '../../../../core/error/failures.dart';
import '../entities/apiary.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<Apiary> apiaries,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> checkAuthStatus();
  Future<Either<Failure, User>> getUserFromToken(String token);
}