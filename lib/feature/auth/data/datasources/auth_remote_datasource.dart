import '../../core/entities/apiary.dart';
import '../../core/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<Apiary> apiaries,
  });
  Future<void> logout();
  Future<User> getUserFromToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // In a real app, you would inject an HTTP client (like Dio) here
  // final Dio httpClient;
  // AuthRemoteDataSourceImpl(this.httpClient);

  @override
  Future<String> login(String email, String password) async {
    // Simulated successful login: always return a token
    await Future.delayed(const Duration(seconds: 1));
    return 'fake_jwt_token_for_$email'; // Return a mock token based on email
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<Apiary> apiaries,
  }) async {
    // This is where you would make the actual API call
    // ...
    // Mock implementation
    // print('Simulating registration for: $name, $email');
    await Future.delayed(const Duration(seconds: 2));
    return User(id: '2', email: email);
  }

  @override
  Future<void> logout() async {
    // Simulated successful logout
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User> getUserFromToken(String token) async {
    // Simulated: always return a mock user from any token
    await Future.delayed(const Duration(milliseconds: 300));
    final email = token.replaceFirst('fake_jwt_token_for_', '');
    return User(id: '1', email: email);
}}