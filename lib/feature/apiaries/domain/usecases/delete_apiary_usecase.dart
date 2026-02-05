import 'package:Softbee/core/error/failures.dart';
import 'package:Softbee/core/usecase/usecase.dart';
import 'package:Softbee/feature/apiaries/domain/repositories/apiary_repository.dart';
import 'package:either_dart/either.dart';

class DeleteApiaryParams {
  final String apiaryId;
  final String userId; // Add userId for authorization check

  DeleteApiaryParams({required this.apiaryId, required this.userId});
}

class DeleteApiaryUseCase implements UseCase<void, DeleteApiaryParams> {
  final ApiaryRepository repository;

  DeleteApiaryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteApiaryParams params) async {
    return await repository.deleteApiary(params.apiaryId, params.userId);
  }
}
