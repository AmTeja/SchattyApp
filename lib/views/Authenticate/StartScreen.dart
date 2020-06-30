import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'AuthHome.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
              text: [
                "Hello.",
                "Welcome To Schatty",
              ],
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              displayFullTextOnTap: false,
              isRepeatingAnimation: false,
              onFinished: pushPage(context),
              onTap: () {
                setState(() {
                  pushPage(context);
                });
              },
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
