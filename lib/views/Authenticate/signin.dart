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

  TextEditingController userNameTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  QuerySnapshot snapshotUserInfo;

  String email;
  String error;

  bool hidePassword = true;
  bool userNameExists = false;
  bool isLoading = false;
  bool incorrectPass = false;

  getUserExists() async {
    databaseMethods.getUserByUserName(userNameTEC.text).then((val) {
      if (val != null || val != 0) {
        setState(() {
          userNameExists = true;
          print("User exists");
        });
      }
    });
  }

  signIn() async {
    if (formKey.currentState.validate()) {
      try {
        databaseMethods.getUserByUserName(userNameTEC.text).then((val) async {
          if (val != null || val != 0) {
            setState(() {
              userNameExists = true;
              print("User exists");
              isLoading = true;
            });
            try {
              await Firestore.instance
                  .collection("users")
                  .where("username", isEqualTo: userNameTEC.text)
                  .getDocuments()
                  .then((value) async {
                print(value.documents[0].data["email"]);
                email = value.documents[0].data["email"];
              });
              if (email != null) {
                FirebaseAuth _auth = FirebaseAuth.instance;
                AuthResult result = await _auth.signInWithEmailAndPassword(
                    email: email, password: passwordTEC.text);
                FirebaseUser firebaseUser = result.user;

                if (firebaseUser != null && firebaseUser.isEmailVerified) {
                  HelperFunctions.saveUserLoggedInSharedPreference(true);
                  HelperFunctions.saveUserEmailSharedPreference(email);
                  HelperFunctions.saveIsGoogleUser(false);
                  Constants.ownerEmail = email;
                  print("Logged In true");
                  await databaseMethods
                      .getUserByUserEmail(email)
                      .then((value) async {
                    snapshotUserInfo = value;
                    HelperFunctions.saveUserNameSharedPreference(
                        await snapshotUserInfo.documents[0].data["username"]);
                    Constants.ownerName =
                        await snapshotUserInfo.documents[0].data["username"];
                  });
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoom(),
                      ));
                } else {
                  await firebaseUser.sendEmailVerification();
                  setState(() {
                    error = "Email not Verified. Verification mail was sent!";
                    isLoading = false;
                  });
                }
              }
            } catch (e) {
              print(e);
              if (e.message == "Invalid value") {
                setState(() {
                  error = "Username does not exist";
                  isLoading = false;
                });
              } else {
                setState(() {
                  error = e.message;
                  isLoading = false;
                });
              }
            }
          }
        });
      } catch (e) {
        print(e);
        if (e.message == "Invalid value") {
          setState(() {
            error = "Username does not exist";
            isLoading = false;
          });
        }
        else {
          setState(() {
            error = e.message;
            isLoading = false;
          });
        }
      }
    }
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
      body: !isLoading ? GestureDetector(
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
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 40, top: 20),
                      child: Text(
                        "Welcome back.",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                  ),
                  showAlert(),
                  SizedBox(height: 20,),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: NameValidator.validate,
                          controller: userNameTEC,
                          style: simpleTextStyle(),
                          decoration: new InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 15, top: 20, bottom: 20),
                              labelText: "Username",
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
                            obscureText: hidePassword,
                            validator: PasswordValidator.validate,
                            controller: passwordTEC,
                            style: simpleTextStyle(),
                            decoration: new InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(Icons.remove_red_eye),
                                  color: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                ),
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
      ) :
      loadingScreen(),
    );
  }

}
