import 'package:flutter/material.dart';
import 'package:ping_me/utils/custom_text_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffffda8c),
                  ),
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
                              text: "Sign In with ",
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
