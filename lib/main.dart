import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_me/screen/auth/login_screen.dart';
import 'package:ping_me/screen/splash_screen.dart';

import 'firebase_options.dart';

/// --- global object for accessing device screen --- ///
late Size deviceSize;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Show in full screen --- ///
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// always portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
