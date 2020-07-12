import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Authenticate/signin.dart';
import 'package:schatty/views/Authenticate/signup.dart';
import 'package:schatty/views/Feed/FeedPage.dart';

import '../Chatroom/MainChatsRoom.dart';


class AuthHome extends StatefulWidget {
  @override
  _AuthHomeState createState() => _AuthHomeState();
}

class _AuthHomeState extends State<AuthHome> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  DarkThemeProvider darkThemeProvider = new DarkThemeProvider();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Color(0xff111111),
            borderRadius: BorderRadius.circular(46),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(217, 0, 0, 0),
                offset: Offset(2, 3),
                blurRadius: 5,
                spreadRadius: 6,
              )
          ],
          ),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  "Schatty",
                  style: TextStyle(
                    fontSize: 70,
//                  fontFamily: 'odibeeSans',
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    signInButton(),
                    SizedBox(
                      height: 20,
                    ),
                    signUpButton(),
                    SizedBox(
                      height: 30,
                    ),
                    googleButton(),
                  ],
                ),
              )
            ],
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
      highlightElevation: 4,
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
//                  fontFamily: 'North Regular',
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
        signInWithGoogle(context);
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
  Preferences helperFunctions = new Preferences();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  void signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult =
      await _auth.signInWithCredential(authCredential);
      final FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      //Defining terms to update in database.
      String username = user.displayName.replaceAll(" ", "").toLowerCase();
      String email = user.email;
      String profilePicURL =
          "https://www.searchpng.com/wp-content/uploads/2019/02/Deafult-Profile-Pitcher.png";
      String uid = user.uid;

      if (user != null && authResult.additionalUserInfo.isNewUser) {
        Map<String, String> userInfoMap = {
          //Making MAP for firebase
          "username": username,
          "email": email,
          "searchKey": username.substring(0, 1).toUpperCase(),
          "photoURL": profilePicURL,
          "uid": uid,
          "usernameIndex" : await makeIndex(username),
        };

        await databaseMethods.uploadUserInfo(userInfoMap, uid);
        Preferences.saveUserNameSharedPreference(username);
        Preferences.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      }
    else if(user !=null && !authResult.additionalUserInfo.isNewUser)
      {
        print("Already Exists");
        Preferences.saveUserNameSharedPreference(username.toLowerCase());
        Preferences.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FeedPage()));
      }
    } catch (e) {
    print(e.toString());
    }
  }

  makeIndex(String username) {
    try {
      print('Called');
      List<String> indexList = [];
      for (int i = 0; i < username.length; i++) {
        for (int y = 0; y < username.length + 1; y++) {
          indexList.add(username.substring(0, y).toLowerCase());
        }
      }
      return indexList;
    } catch (e) {
      print('Error making index: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
