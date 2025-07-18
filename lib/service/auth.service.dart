import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/http.core.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static final HttpClient _http = HttpClient();

  static Future<bool> login(String id) async {
    final response = await _http.post('/token', data: {'id': id});
    final token = response.data['access_token'];
    if (token != null) {
      await _storage.write(key: 'access_token', value: token);
      await _http.authorize();
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await _http.unauthorize();
  }

  static Future<bool> get isTokenSaved async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
