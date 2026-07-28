import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  /// Melakukan proses login.
  ///
  /// Jika berhasil, token dan data pengguna akan disimpan
  /// ke SharedPreferences sebagai sesi login.
  Future<LoginResponse> login(
      String username,
      String password,
      ) async {
    try {
      final response = await ApiService.post(
        '/login',
        {
          'username': username,
          'password': password,
        },
      );

      final json = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(json);

      if (loginResponse.status == 'success' &&
          loginResponse.token != null &&
          loginResponse.user != null) {
        await saveSession(
          loginResponse.token!,
          loginResponse.user!,
        );
      }

      return loginResponse;
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Gagal menghubungkan ke server: $e',
      );
    }
  }

  /// Menyimpan token dan data pengguna ke SharedPreferences.
  Future<void> saveSession(
      String token,
      UserModel user,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyToken, token);
    await prefs.setString(
      _keyUser,
      jsonEncode(user.toJson()),
    );
  }

  /// Mengecek apakah pengguna sudah login.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyToken);
  }

  /// Mengambil data pengguna dari sesi lokal.
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);

    if (userJson == null) {
      return null;
    }

    try {
      return UserModel.fromJson(
        jsonDecode(userJson),
      );
    } catch (_) {
      return null;
    }
  }

  /// Mengambil token autentikasi dari sesi lokal.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Menghapus sesi login (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}