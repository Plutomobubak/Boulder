import 'package:boulder/main_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/boulder.dart';
import 'models/draw_point.dart';
import 'utils/auth_screen.dart';
import 'package:flutter/services.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BoulderAdapter());
  Hive.registerAdapter(DrawPointAdapter());

  await Hive.openBox<Boulder>('boulders');
  await Hive.openBox('auth');
  await Hive.openBox('settings');

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final bool isDarkMode = !box.get('lightMode', defaultValue: false);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Boulder App',
          theme: isDarkMode
              ? ThemeData.dark()
              : ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: MainPage(), // or whatever your main page is
        );
      },
    );
  }
}


