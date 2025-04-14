import 'package:flutter/material.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/home_screen.dart';
import 'package:ping_me/utils/custom_text_style.dart';

import '../../helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController animationController;
  var radiusList = [150.0, 200.0, 250.0, 300.0, 350.0];
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
      lowerBound: 0.4,
    );
    animationController.addListener(() {
      setState(() {});
    });
    animationController.repeat();
  }
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void loginWithGoogle(BuildContext context) async {
    /// Show progress bar
    Dialogs.myShowProgressbar(context);
    final user = await _authService.signInWithGoogle();
    /// Dismiss the progress bar
    Navigator.pop(context);
    if (user != null) {
      // Navigate to home screen after selecting email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
     Dialogs.myShowSnackBar(context, "Something went wrong", Colors.red, Colors.white);
    }
  }



  late Size deviceSize;
  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            /// --- Ripple animations --- ///
            Positioned(
              top: 20,
              child: Container(
                height: deviceSize.height * 0.6,
                width: deviceSize.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...radiusList.map((radius) {
                      final scale = animationController.value;
                      final int alphaValue = ((1.0 - scale) * 255)
                          .toInt()
                          .clamp(0, 255);
                      return Container(
                        width: radius * animationController.value,
                        height: radius * animationController.value,
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(alphaValue),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                    ClipOval(
                      child: Image.asset(
                        "assets/icons/app_logo.png",
                        height: deviceSize.height * 0.2,
                        width: deviceSize.height * 0.2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// --- Elevated Button --- ///
            Positioned(
              bottom: 80,
              left: deviceSize.width * 0.15,
              child: SizedBox(
                width: deviceSize.width * 0.7,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffffda8c),
                  ),
                  onPressed: ()=> loginWithGoogle(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        "assets/images/google.png",
                        height: 30,
                        width: 30,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Login In with ",
                              style: myTextStyle18(context),
                            ),
                            TextSpan(
                              text: "Google",
                              style: myTextStyle18(
                                context,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
