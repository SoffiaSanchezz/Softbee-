import 'package:either_dart/either.dart';
import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/core/usecase/usecase.dart';
import 'package:Softbee/feature/beehive/domain/repositories/beehive_repository.dart';

class DeleteBeehiveParams {
  final String beehiveId;
  final String apiaryId; // Required for backend authorization

  DeleteBeehiveParams({required this.beehiveId, required this.apiaryId});
}

class DeleteBeehiveUseCase implements UseCase<void, DeleteBeehiveParams> {
  final BeehiveRepository repository;

  DeleteBeehiveUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBeehiveParams params) async {
    return await repository.deleteBeehive(params.beehiveId, params.apiaryId);
  }
}
