import 'package:flutter/material.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/views/editProfile.dart';

void main() {
  runApp(MyApp());

//  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;
  var counter = HelperFunctions.getUserFirstTime();
  @override
  void initState() {
    getState();
    super.initState();
  }

  getState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isUserLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schatty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xffffffff),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EditProfile(),
//      home: isUserLoggedIn!= null ? (isUserLoggedIn ? ChatRoom() : AuthHome()) : StartScreen(),
    );
  }
}

