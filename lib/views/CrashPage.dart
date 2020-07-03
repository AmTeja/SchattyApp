import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashPage extends StatefulWidget {
  @override
  _CrashPageState createState() => _CrashPageState();
}

class _CrashPageState extends State<CrashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crash"),),
      body: Center(
        child: Container(
          child: FlatButton(
            onPressed: () {
              Crashlytics.instance.crash();
            },
            child: Text("crash"),
          ),
        ),
      ),
    );
  }
}
