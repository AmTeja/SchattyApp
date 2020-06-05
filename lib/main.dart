import 'package:flutter/material.dart';
import 'package:schatty/helper/NavigationService.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/views/Authenticate/AuthHome.dart';
import 'package:schatty/views/Authenticate/StartScreen.dart';
import 'package:schatty/views/MainChatsRoom.dart';

void main() {
  runApp(MyApp());
  //  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NavigationService navigationService = new NavigationService();
  bool isUserLoggedIn = false;

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
      routes: {
        '/ChatsRoom': (context) => ChatRoom(),
      },
      title: 'Schatty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xffffffff),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
//      home: EditProfile(),
      home: isUserLoggedIn != null
          ? (isUserLoggedIn ? ChatRoom() : AuthHome())
          : StartScreen(),
    );
  }
}

