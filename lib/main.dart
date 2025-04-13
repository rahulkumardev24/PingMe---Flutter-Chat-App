import 'package:flutter/material.dart';
import 'package:ping_me/screen/auth/login_screen.dart';
import 'package:ping_me/screen/home_screen.dart';

/// --- global object for accessing device screen --- ///
late Size deviceSize ;

void main() {
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
      home: LoginScreen()
    );
  }
}

