import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:Softbee/feature/auth/data/datasources/auth_local_datasource.dart';
import 'package:dio/dio.dart';

abstract class ApiaryRemoteDataSource {
  Future<List<Apiary>> getApiaries(String token);
}

class ApiaryRemoteDataSourceImpl implements ApiaryRemoteDataSource {
  final Dio httpClient;
  final AuthLocalDataSource localDataSource;

  ApiaryRemoteDataSourceImpl(this.httpClient, this.localDataSource);

  @override
  Future<List<Apiary>> getApiaries(String token) async {
    try {
      final response = await httpClient.get(
        '/api/v1/apiaries',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> apiariesJson = response.data;
        return apiariesJson.map((json) => Apiary.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Error al obtener apiarios',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ??
              'Error de red: ${e.response!.statusCode}',
        );
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
