import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Center(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  themeChange.darkTheme = !themeChange.darkTheme;
                },
                child: Container(
                    height: 100,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            "Dark Theme",
                            style: TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                        Switch(
                          value: themeChange.darkTheme,
                          onChanged: (value) {
                            themeChange.darkTheme = value;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
//                            color: Color.fromARGB(255, 141, 133, 133),
//                            width: 0.1
                          )),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  SendMail(context);
                },
                child: Container(
                    height: 100,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            "Send Feedback",
                            style: TextStyle(
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                          )),
                    )),
              ),
            ],
          ),
        ));
  }

  // ignore: non_constant_identifier_names
  SendMail(BuildContext context) async
  {
    try {
      final Email email = Email(
        body: "Test Body",
        subject: "Feedback",
        recipients: ['schattyapp@gmail.com'],
        isHTML: false,
      );
      await FlutterEmailSender.send(email);
    }
    catch (error) {
      Fluttertoast.showToast(msg: "An error occurred sending feedback: $error");
    }
  }
}
