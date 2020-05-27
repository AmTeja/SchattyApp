import 'package:flutter/material.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/views/Authenticate/signin.dart';
import 'package:schatty/views/Authenticate/signup.dart';

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
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(100, 39, 38, 38)
          ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
//              tileMode: TileMode.mirror,
            )
        ),
        child: Center(
          child: Container(
            color: Colors.transparent,
            child: Container(
              width: 370,
              height: 650,
              decoration: BoxDecoration(
                boxShadow: [
                  new BoxShadow(
//                      color: Colors.red,
                    color: Color.fromARGB(217, 0, 0, 0),
                    offset: new Offset(2, 3),
                    blurRadius: 5,
                    spreadRadius: 6,
                  )
                ],
                borderRadius: BorderRadius.circular(46),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 14, 14, 14),
                    Color.fromARGB(100, 46, 45, 45)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 100, top: 80),
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Schatty",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 70,
                          fontFamily: 'North Regular',
                        ),
                      ),
                    ),
                  ),
                  signInButton(),
                  SizedBox(
                    height: 20,
                  ),
                  signUpButton(),
                  SizedBox(
                    height: 20,
                  ),
                  googleButton(),
                  SizedBox(height: 180,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton() {
    return MaterialButton(
      splashColor: Colors.grey,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 80, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.email,
              color: Colors.black,
            ),
            SizedBox(width: 40,),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontFamily: 'North Regular',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget signUpButton() {
    return MaterialButton(
      splashColor: Colors.black26,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUp()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      color: Colors.white,
      highlightElevation: 3,

      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 80, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.account_circle,
              color: Colors.black,
            ),
            SizedBox(width: 40,),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.black54,
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
        HelperFunctions.saveUserNameSharedPreference(
            username.replaceAll(" ", ""));
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        print(username.replaceAll(" ", ""));
        HelperFunctions.saveIsGoogleUser(true);
        Navigator.pushReplacement(
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
