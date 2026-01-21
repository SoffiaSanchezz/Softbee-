// Placeholder for local authentication data source
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // TODO: Implement local data source logic using shared_preferences or flutter_secure_storage
  @override
  Future<void> deleteToken() async {
    // TODO: implement deleteToken
  }

  @override
  Future<String?> getToken() async {
    // TODO: implement getToken
    return null;
  }

  @override
  Future<void> saveToken(String token) async {
    // TODO: implement saveToken
  }
}
