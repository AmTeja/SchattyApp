import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';

import '../AdView.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ListView(
            children: [
              Container(
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
              InkWell(
                onTap: () {
                  showAd(context);
                },
                child: Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View an ad",
                        style: TextStyle(
                          fontSize: 30.0,
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(),
                      )),
                ),
              )
            ],
          ),
        ));
  }

  showAd(context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ViewAd(),
    ));
  }

}
