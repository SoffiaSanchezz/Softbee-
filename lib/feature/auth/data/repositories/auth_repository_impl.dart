import 'package:Softbee/feature/auth/data/datasources/auth_local_datasource.dart';
import 'package:Softbee/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:either_dart/either.dart';

import '../../../../core/error/failures.dart';
import '../../core/entities/apiary.dart';
import '../../core/entities/user.dart';
import '../../core/repositories/auth_repository.dart';
// import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final token = await remoteDataSource.login(email, password);
      await localDataSource.saveToken(token);
      return Right(token);
    } catch (e) {
      return const Left(ServerFailure('Error al iniciar sesión'));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Right(null);
      }
      final user = await remoteDataSource.getUserFromToken(token);
      return Right(user);
    } catch (e) {
      await localDataSource.deleteToken();
      return const Left(AuthFailure('Session expired. Please log in again.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.deleteToken();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error during logout'));
    }
  }

  @override
  Future<Either<Failure, User>> getUserFromToken(String token) async {
    try {
      final user = await remoteDataSource.getUserFromToken(token);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Error al obtener usuario del token'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<Apiary> apiaries,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        apiaries: apiaries,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}