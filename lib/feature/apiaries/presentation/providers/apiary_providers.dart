import 'package:Softbee/core/network/dio_client.dart';
import 'package:Softbee/feature/apiaries/data/datasources/apiary_remote_datasource.dart';
import 'package:Softbee/feature/apiaries/data/repositories/apiary_repository_impl.dart';
import 'package:Softbee/feature/apiaries/domain/repositories/apiary_repository.dart';
import 'package:Softbee/feature/apiaries/domain/usecases/get_apiaries.dart';
import 'package:Softbee/feature/apiaries/presentation/controllers/apiaries_controller.dart';
import 'package:Softbee/feature/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiaryRemoteDataSourceProvider = Provider<ApiaryRemoteDataSource>((ref) {
  final dio = ref.read(dioClientProvider);
  final localDataSource = ref.read(
    authLocalDataSourceProvider,
  ); // Reuse auth local data source for token
  return ApiaryRemoteDataSourceImpl(dio, localDataSource);
});

final apiaryRepositoryProvider = Provider<ApiaryRepository>((ref) {
  return ApiaryRepositoryImpl(
    remoteDataSource: ref.read(apiaryRemoteDataSourceProvider),
    localDataSource: ref.read(
      authLocalDataSourceProvider,
    ), // Reuse auth local data source for token
  );
});

final getApiariesUseCaseProvider = Provider<GetApiariesUseCase>((ref) {
  return GetApiariesUseCase(ref.read(apiaryRepositoryProvider));
});

final apiariesControllerProvider =
    StateNotifierProvider<ApiariesController, ApiariesState>((ref) {
      final getApiariesUseCase = ref.read(getApiariesUseCaseProvider);
      final authController = ref.watch(authControllerProvider.notifier);
      return ApiariesController(
        getApiariesUseCase: getApiariesUseCase,
        authController: authController,
      );
    });
