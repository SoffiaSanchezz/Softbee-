import 'package:dio/dio.dart';
import '../models/maya_response_model.dart';

abstract class MayaRemoteDataSource {
  Future<Map<String, dynamic>> askMaya({
    required String prompt,
    String? sessionId,
    String agentId = 'general',
    String provider = 'gemini',
    Map<String, dynamic>? context,
    String? token,
  });
}

class MayaRemoteDataSourceImpl implements MayaRemoteDataSource {
  final Dio httpClient;

  MayaRemoteDataSourceImpl(this.httpClient);

  @override
  Future<Map<String, dynamic>> askMaya({
    required String prompt,
    String? sessionId,
    String agentId = 'general',
    String provider = 'gemini',
    Map<String, dynamic>? context,
    String? token,
  }) async {
    try {
      final response = await httpClient.post(
        '/api/v1/ai/ask',
        data: {
          'prompt': prompt,
          if (sessionId != null) 'session_id': sessionId,
          'agent_id': agentId,
          'provider': provider,
          if (context != null) 'context': context,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Error comunicándose con Maya',
      );
    }
  }
}
