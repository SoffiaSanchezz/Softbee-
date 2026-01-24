import 'package:dio/dio.dart';
import '../../core/entities/user.dart';
import 'auth_local_datasource.dart'; // Importar AuthLocalDataSource

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> registerUser(
      String username,
      String email,
      String phone,
      String password);
  Future<String> login(String email, String password);
  Future<void> logout();
  Future<User> getUserFromToken(String token);
  Future<void> createApiary(String userId, String apiaryName, String location,
      int beehivesCount, bool treatments, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio httpClient;
  final AuthLocalDataSource localDataSource; // Inyectar AuthLocalDataSource

  AuthRemoteDataSourceImpl(this.httpClient, this.localDataSource); // Constructor actualizado

  @override
  Future<Map<String, dynamic>> registerUser(
    String username,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await httpClient.post(
        '/api/v1/auth/register',
        data: {
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': password,
        },
      );

      if (response.statusCode == 201) {
        final token = response.data['access_token'];
        final userData = response.data['user'];

        if (token != null && userData != null) {
          final user = User.fromJson(userData);
          await localDataSource.saveUser(user);
          await localDataSource.saveToken(token); // Guardar el token aquí
          return {
            'access_token': token,
            'user': user,
          };
        } else {
          throw Exception('Token o datos de usuario no recibidos del servidor');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Error de registro');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ?? e.response!.data['message'] ?? 'Error de red: ${e.response!.statusCode}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await httpClient.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final userData = response.data['user'];

        if (token != null && userData != null) {
          final user = User.fromJson(userData);
          await localDataSource.saveUser(user); // Guardar el objeto User
          await localDataSource.saveToken(token); // Guardar el token también para mantener la sesión
          return token;
        } else {
          throw Exception('Token o datos de usuario no recibidos del servidor');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Error de inicio de sesión');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Error de red: ${e.response!.statusCode}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> createApiary(String userId, String apiaryName, String location, int beehivesCount, bool treatments, String token) async {
    try {
      await httpClient.post(
        '/api/v1/apiaries',
        data: {
          'user_id': userId,
          'name': apiaryName,
          'location': location,
          'treatments': treatments,
          'beehives_count': beehivesCount, 
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Error al crear apiario: ${e.response!.statusCode}');
      } else {
        throw Exception('Error de conexión al crear apiario: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado al crear apiario: $e');
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
    await localDataSource.deleteUser();
  }

  @override
  Future<User> getUserFromToken(String token) async {
    final user = await localDataSource.getUser();
    if (user != null) {
      return user;
    } else {
      throw Exception('No se encontró información de usuario local.');
    }
  }

  // Helper para generar username. En el futuro, esto podría ser más sofisticado.
  static String generateUsername(String email) {
    return email.split('@')[0].replaceAll('.', '_').replaceAll('-', '_');
  }
}
