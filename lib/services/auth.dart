import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../utils/consts.dart'; // make sure your apiUrl is here

class AuthService {
  final Box authBox = Hive.box('auth');

  /// Login with username & password
  Future<http.Response> login(String username, String password) async {
    final url = Uri.parse("$apiUrl/token");
    return await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'username': username, 'password': password},
    );
  }

  /// Register new account
  Future<http.Response> register(String username, String password) async {
    final url = Uri.parse("$apiUrl/register");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': username, 'password': password}),
    );
  }

  /// Save tokens & username in Hive
  Future<void> saveTokens(String token, String refreshToken, String username) async {
    await authBox.put('token', token);
    await authBox.put('refresh_token', refreshToken);
    await authBox.put('username', username);
  }

  /// Refresh expired access token
  Future<bool> refreshToken() async {
    final refreshToken = authBox.get('refresh_token');
    if (refreshToken == null) return false;

    final url = Uri.parse("$apiUrl/refresh");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['access_token'], data['refresh_token'], authBox.get('username'));
      return true;
    } else {
      await logout();
      return false;
    }
  }

  /// Remove tokens to log out user
  Future<void> logout() async {
    await authBox.deleteAll(['token', 'refresh_token', 'username']);
  }
}
