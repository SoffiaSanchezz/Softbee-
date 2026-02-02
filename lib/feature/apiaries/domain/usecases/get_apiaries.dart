import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/core/usecase/usecase.dart';
import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/apiaries/domain/repositories/apiary_repository.dart';
import 'package:either_dart/either.dart';

class GetApiariesUseCase implements UseCase<List<Apiary>, NoParams> {
  final ApiaryRepository repository;

  GetApiariesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Apiary>>> call(NoParams params) async {
    return await repository.getApiaries();
  }
}
