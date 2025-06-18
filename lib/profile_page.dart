import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'utils/auth_screen.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = false;
  bool isOnline = true;
  String? username;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _subscribeConnectivity();
  }

  void _subscribeConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkLoginStatus() async {
    final authBox = Hive.box('auth');
    final token = authBox.get('token');
    final savedUsername = authBox.get('username');

    bool validToken = false;

    if (token != null) {
      try {
        validToken = !JwtDecoder.isExpired(token);
      } catch (e) {
        validToken = false;
      }
    }

    setState(() {
      isLoggedIn = validToken;
      username = validToken ? savedUsername : null;
    });

    if (!validToken) {
      // Optionally clear invalid tokens
      await authBox.deleteAll(['token', 'refresh_token']);
    }
  }

  Future<void> _logout() async {
    final authBox = Hive.box('auth');
    await authBox.deleteAll(['token','refresh_token','username']);
    setState(() {
      isLoggedIn = false;
      username = null;
    });
  }

  Widget _buildProfile() {
    return Text("Logged in as $username");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoggedIn
          ? _buildProfile()
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You are not logged in.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            child: const Text('Login'),
          ),
          if (!isOnline)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'No internet connection. You can still browse offline data.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

