import 'package:boulder/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/auth_screen.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'services/settings_sys.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver{
  final AuthService _authService = AuthService();
  bool isLoggedIn = false;
  bool isOnline = true;
  String? username;

  // Settings
  bool notificationsEnabled = true;
  bool lightMode = false;
  String gradeSystem = 'V-Scale';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
    _subscribeConnectivity();
    _loadSettings();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
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

      if (!validToken) {
        // Try to refresh token automatically
        final didRefresh = await _authService.refreshToken();
        if (didRefresh) {
          final newToken = authBox.get('token');
          validToken = newToken != null && !JwtDecoder.isExpired(newToken);
        }
      }
    }

    setState(() {
      isLoggedIn = validToken;
      username = validToken ? savedUsername : null;
    });

    if (!validToken) {
      await authBox.deleteAll(['token', 'refresh_token', 'username']);
    }
  }
  Future<void> _logout() async {
    await _authService.logout();
    setState(() {
      isLoggedIn = false;
      username = null;
    });
  }

  Future<void> _loadSettings() async {
    setState(() async {
      notificationsEnabled = await Settings.get('notificationsEnabled', true);
      lightMode = await Settings.get('lightMode', false);
      gradeSystem = await Settings.get('gradeSystem', 'V-Scale');
    });
  }

  Future<void> _saveSettings() async {
    Settings.set('notificationsEnabled', notificationsEnabled);
    Settings.set('lightMode', lightMode);
    Settings.set('gradeSystem', gradeSystem);
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile picture
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(
            'https://via.placeholder.com/150', // Replace with user profile URL if you have one
          ),
        ),
        const SizedBox(height: 10),
        isLoggedIn
            ? Text(
          "Logged in as $username",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
            : const Text(
          'You are not logged in.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isLoggedIn
              ? _logout
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
          },
          child: Text(isLoggedIn ? 'Logout' : 'Login'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: notificationsEnabled,
          onChanged: (value) {
            setState(() {
              notificationsEnabled = value;
            });
            _saveSettings();
          },
        ),
        SwitchListTile(
          title: const Text('Light Mode'),
          value: lightMode,
          onChanged: (value) {
            setState(() {
              lightMode = value;
            });
            _saveSettings();
          },
        ),
        const SizedBox(height: 10),
        const Text(
          'Grade System',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        DropdownButton<String>(
          value: gradeSystem,
          onChanged: (String? newValue) {
            setState(() {
              gradeSystem = newValue!;
            });
            _saveSettings();
          },
          items: <String>['V-Scale', 'French', 'Yosemite']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(height: 40),
    Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
    Row(
    children: [
    Icon(Icons.bug_report, color: Colors.redAccent),
    SizedBox(width: 10),
    Expanded(
    child: Text(
    "Please report any issues/bugs",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    ),
    ],
    ),
    SizedBox(height: 12),
    Row(
    children: [
    Expanded(
    child: Text(
    "Also accepting any suggestions and PRs :)",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    ),
    ],
    ),]
    ),),
        const SizedBox(height: 20),

        // GitHub Button
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            const url = 'https://github.com/plutomobubak/boulder'; // Replace with your GitHub repo URL
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open GitHub link')),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'GitHub Repository',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Email Button
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final email = Uri(
                scheme: 'mailto',
                path: 'blahnik.tomas@gmail.com',
                queryParameters: {
                  'subject': 'Boulder App'
                }
            ).toString();

            if (await canLaunch(email)) {
              await launch(email);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open email client')),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.email,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Contact Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileSection(),
            if (!isOnline)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'No internet connection. You can still browse offline data.',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _buildSettingsSection(),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }
}
