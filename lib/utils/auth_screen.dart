import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:boulder/main_page.dart';

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

  final String baseUrl = "http://10.0.2.2:8000"; // use correct IP/domain

  void _submit() async {
    setState(() => _loading = true);
    final authBox = Hive.box('auth');

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text;

      http.Response response;

      if (_isLogin) {
        // === LOGIN ===
        final url = Uri.parse("$baseUrl/token");
        response = await http.post(
          url,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            'username': username,
            'password': password,
          },
        );
      } else {
        // === REGISTER ===
        final url = Uri.parse("$baseUrl/register");
        response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'username': username, 'password': password}),
        );

        // If register succeeded, login user immediately
        if (response.statusCode == 200) {
          final loginUrl = Uri.parse("$baseUrl/token");
          response = await http.post(
            loginUrl,
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: {'username': username, 'password': password},
          );
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final refresh_token = data['refresh_token'];

        await authBox.put('token', token);
        await authBox.put('refresh_token', refresh_token);
        await authBox.put('username', _usernameController.text);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      } else {
        _showError("Error: ${response.body}");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    }

    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
