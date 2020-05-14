import 'package:flutter/material.dart';
import 'package:schatty/helper/authenticate.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/views/chatsroom.dart';

import 'services/RSAEncryption.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isUserLoggedIn = false;
  RSAEncryption encryption = new RSAEncryption();

  @override
  void initState() {
    getLoggedInState();
    futureKeyPair = encryption.getKeyPair();
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffff758c),
        scaffoldBackgroundColor: Color(0xffffffff),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: isUserLoggedIn != null
            ? (isUserLoggedIn ? ChatRoom() : Authenticate())
            : Authenticate()
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

