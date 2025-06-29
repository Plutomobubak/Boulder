import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:boulder/main_page.dart';
import 'package:boulder/services/auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  final AuthService _authService = AuthService();

  void _submit() async {
    setState(() => _loading = true);

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text;

      http.Response response;

      if (_isLogin) {
        response = await _authService.login(username, password);
      } else {
        response = await _authService.register(username, password);

        if (response.statusCode == 200) {
          // Register succeeded → login immediately
          response = await _authService.login(username, password);
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final refreshToken = data['refresh_token'];

        await _authService.saveTokens(token, refreshToken, username);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      } else if (response.statusCode == 401) {
        _showError("❌ Incorrect username or password.");
      } else if (response.statusCode == 400) {
        _showError("❌ Invalid request. Please check your input.");
      } else {
        _showError("❌ Server error: ${response.statusCode}\n${response.body}");
      }
    } on SocketException {
      _showError("🚫 Cannot connect to server. Please check your internet connection.");
    } catch (e) {
      _showError("❌ Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? "Don't have an account? Register"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
