import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:either_dart/either.dart';

abstract class ApiaryRepository {
  Future<Either<Failure, List<Apiary>>> getApiaries();
}
