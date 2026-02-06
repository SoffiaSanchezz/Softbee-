import 'package:either_dart/either.dart';
import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/core/usecase/usecase.dart';
import 'package:Softbee/feature/beehive/domain/entities/beehive.dart';
import 'package:Softbee/feature/beehive/domain/repositories/beehive_repository.dart';

class GetBeehivesByApiaryUseCase implements UseCase<List<Beehive>, String> {
  final BeehiveRepository repository;

  GetBeehivesByApiaryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Beehive>>> call(String params) async {
    return await repository.getBeehivesByApiary(params);
  }
}
