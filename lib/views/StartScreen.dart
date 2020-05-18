import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'NewSignIn.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
            child: SizedBox(
          width: 250,
          child: Center(
            child: FadeAnimatedTextKit(
              duration: Duration(milliseconds: 2000),
              text: ["Hello.", "Tap to continue."],
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              isRepeatingAnimation: false,
              onFinished: pushPage(context),
            ),
          ),
        )),
      ),
    );
  }

  pushPage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => AuthHome()));
  }
}
