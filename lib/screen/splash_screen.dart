import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/screen/auth/login_screen.dart';
import 'package:ping_me/screen/home_screen.dart';
import 'package:ping_me/utils/custom_text_style.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
      lowerBound: 0.5,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    Future.delayed(Duration(seconds: 3), () {
      /// exit from full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );

      final User? user = APIs.auth.currentUser;
      if(user != null){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6e8efb),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            ScaleTransition(
              scale: _animation,
              child: Image.asset("assets/icons/app_logo.png", height: 300),
            ),
            Spacer(),
            Text(
              'Ping Me',
              style: myTextStyle36(
                context,
                fontWeight: FontWeight.bold,
                fontColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Connecting people...',
              style: myTextStyle15(context, fontColor: Colors.white70),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
