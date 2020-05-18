import 'package:flutter/material.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/views/StartScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isUserLoggedIn = false;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }


  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        isUserLoggedIn = value;
        print(isUserLoggedIn);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schatty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffff758c),
        scaffoldBackgroundColor: Color(0xffffffff),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomeScreen(),
//        home: isUserLoggedIn != null
//            ? (isUserLoggedIn ? ChatRoom() : Authenticate())
//            : Authenticate()
    );
  }
}

class NullWidget extends StatefulWidget {
  @override
  _NullWidgetState createState() => _NullWidgetState();
}

class _NullWidgetState extends State<NullWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

