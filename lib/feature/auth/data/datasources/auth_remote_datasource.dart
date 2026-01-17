import '../../core/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '1', email: email);
  }

  @override
  Future<User> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '2', email: email);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}