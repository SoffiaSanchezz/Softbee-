import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/feature/apiaries/data/datasources/apiary_remote_datasource.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/apiaries/domain/repositories/apiary_repository.dart';
import 'package:Softbee/feature/auth/data/datasources/auth_local_datasource.dart';
import 'package:either_dart/either.dart';

class ApiaryRepositoryImpl implements ApiaryRepository {
  final ApiaryRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ApiaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Apiary>>> getApiaries() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Left(AuthFailure('No authentication token found.'));
      }
      final result = await remoteDataSource.getApiaries(token);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
