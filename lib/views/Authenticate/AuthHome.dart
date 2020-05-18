import 'package:flutter/material.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';

import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Authenticate/signin.dart';
import 'file:///C:/Users/Dell/AndroidStudioProjects/schatty/lib/views/Authenticate/signup.dart';

import '../MainChatsRoom.dart';

class AuthHome extends StatefulWidget {
  @override
  _AuthHomeState createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),
              signInButton(),
              SizedBox(
                height: 20,
              ),
              signUpButton(),
              SizedBox(
                height: 20,
              ),
              googleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 1,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.email,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Signin with Email",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget signUpButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUp()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 1,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Signup with Email",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget googleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 1,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage("assets/images/googlelogo.png"),
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Sign in with Google",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AuthMethods authMethods = new AuthMethods();
  HelperFunctions helperFunctions = new HelperFunctions();

  void signInWithGoogle() {
    authMethods.signInWithGoogle().then((val) {
      if (val != null) {
        String username = authMethods.googleSignIn.currentUser.displayName;
        HelperFunctions.saveUserNameSharedPreference(username);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      } else {}
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
