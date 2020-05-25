import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Authenticate/ForgotPasswordLayout.dart';
import 'package:schatty/views/MainChatsRoom.dart';
import 'package:schatty/widgets/widget.dart';

class SignIn extends StatefulWidget {
  SignIn();

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  QuerySnapshot snapshotUserInfo;

  String error;

  bool isLoading = false;
  bool incorrectPass = false;

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        FirebaseAuth _auth = FirebaseAuth.instance;
        AuthResult result = await _auth.signInWithEmailAndPassword(
            email: emailTEC.text, password: passwordTEC.text);
        FirebaseUser firebaseUser = result.user;

        if (firebaseUser != null) {
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
          Constants.ownerEmail = emailTEC.text;
          print("Logged In true");
          await databaseMethods
              .getUserByUserEmail(emailTEC.text)
              .then((value) async {
            snapshotUserInfo = value;
            HelperFunctions.saveUserNameSharedPreference(
                await snapshotUserInfo.documents[0].data["username"]);
            Constants.ownerName =
                await snapshotUserInfo.documents[0].data["username"];
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(),
              ));
        }
      } catch (e) {
        print(e);
        setState(() {
          error = e.message;
        });
      }

//      authMethods
//          .signInWithEmailAndPassword(emailTEC.text, passwordTEC.text)
//          .then((value) {
//        if (value != null) {
//          HelperFunctions.saveUserLoggedInSharedPreference(true);
//          HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
//          Constants.ownerEmail = emailTEC.text;
//          print("Logged In true");
//          databaseMethods.getUserByUserEmail(emailTEC.text).then((value) {
//            snapshotUserInfo = value;
//            HelperFunctions.saveUserNameSharedPreference(
//                snapshotUserInfo.documents[0].data["username"]);
//            Constants.ownerName =
//            snapshotUserInfo.documents[0].data["username"];
//          });
//          Navigator.pushReplacement(
//              context,
//              MaterialPageRoute(
//                builder: (context) => ChatRoom(),
//              ));
//        } else {
//          AlertDialog(
//            title: Text("Verify Email"),
//            content: Text("Please verify your email to continue."),
//            actions: <Widget>[
//              FlatButton(
//                child: Text("Close"),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              )
//            ],
//          );
//        }
//      });
//    }
//    } else {
//      Fluttertoast.showToast(
//        msg: "Incorrect Email/Password!",
//        toastLength: Toast.LENGTH_LONG,
//        gravity: ToastGravity.BOTTOM,
//      );
//    }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget showAlert() {
    if (error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(error,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    error = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(height: 0,);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: appBarMain(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Color.fromARGB(100, 39, 38, 38)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
//              tileMode: TileMode.mirror,
              )),
          child: Center(
            child: Container(
              width: 370,
              height: 620,
              decoration: BoxDecoration(
                boxShadow: [
                  new BoxShadow(
                      color: Color.fromARGB(217, 0, 0, 0),
                      offset: new Offset(2, 3),
                      blurRadius: 5,
                      spreadRadius: 6)
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
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 40, top: 20),
                    child: Text(
                      "Welcome back.",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                  showAlert(),
                  SizedBox(height: 20,),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: EmailValidator.validate,
                          controller: emailTEC,
                          style: simpleTextStyle(),
                          decoration: new InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 15, top: 20, bottom: 20),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.white60,
                              ),
                              border: new OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
//                                  borderSide: BorderSide(color: Colors.blue)
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            obscureText: true,
                            validator: PasswordValidator.validate,
                            controller: passwordTEC,
                            style: simpleTextStyle(),
                            decoration: new InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 15, top: 20, bottom: 20),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                    color: Colors.white60, fontSize: 18),
                                border: new OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: CupertinoColors.black),
                                  borderRadius: BorderRadius.circular(40),
                                ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()));
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Forgot Password?",
                          style: simpleTextStyle(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () {
                      signIn();
                    },
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 90),
                    textColor: Colors.black,
                    splashColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    elevation: 4,
                    child: Text("Sign in"),
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
