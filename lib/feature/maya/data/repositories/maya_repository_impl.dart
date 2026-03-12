import 'package:either_dart/either.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/maya_repository.dart';
import '../datasources/maya_remote_datasource.dart';
import '../models/maya_response_model.dart';

class MayaRepositoryImpl implements MayaRepository {
  final MayaRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  MayaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String prompt,
    String? sessionId,
    String agentId = 'general',
    String provider = 'gemini',
    Map<String, dynamic>? context,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final responseMap = await remoteDataSource.askMaya(
        prompt: prompt,
        sessionId: sessionId,
        agentId: agentId,
        provider: provider,
        context: context,
        token: token,
      );

      final model = MayaResponseModel.fromJson(responseMap);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
