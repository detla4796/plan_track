import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _keyUserEmail = 'userEmail';
  static const _keyUserPassword = 'userPassword';
  static const _keyUserName = 'userName';
  static const _keyUserToken = 'userToken';

  Future<bool> register(String email, String password, {String? name}) async {
    String? existingEmail = await _storage.read(key: _keyUserEmail);
    if (existingEmail == email) return false;

    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserPassword, value: password);
    if (name != null) {
      await _storage.write(key: _keyUserName, value: name);
    }
    await _storage.write(key: _keyUserToken, value: email);
    return true;
  }

  Future<bool> login(String email, String password) async {
    String? savedEmail = await _storage.read(key: _keyUserEmail);
    String? savedPassword = await _storage.read(key: _keyUserPassword);
    if (email == savedEmail && password == savedPassword) {
      await _storage.write(key: _keyUserToken, value: email);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyUserToken);
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: _keyUserToken);
    return token != null;
  }

  Future<String?> get currentUserId async {
    return await _storage.read(key: _keyUserToken);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }
}