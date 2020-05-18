import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
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

  bool isLoading = false;

  signIn() {
    if (formKey.currentState.validate()) {
      print("Validated");
      HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
      setState(() {
        isLoading = true;
      });

      databaseMethods.getUserByUserEmail(emailTEC.text).then((value) {
        snapshotUserInfo = value;
        HelperFunctions.saveUserNameSharedPreference(
            snapshotUserInfo.documents[0].data["username"]);
      });

      authMethods
          .signInWithEmailAndPassword(emailTEC.text, passwordTEC.text)
          .then((value) {
        if (value != null) {
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          print("Logged In true");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(),
              ));
        } else {
          Fluttertoast.showToast(
            msg: "Incorrect Password, Try again!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBarMain(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xffe6e9f0), Color(0xffeef1f5)])),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlutterLogo(
                    size: 150,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please enter a valid e-mail ID.";
                          },
                          controller: emailTEC,
                          style: simpleTextStyle(),
                          decoration: new InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
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
                            validator: (val) {
                              return passwordTEC.text.length >= 8
                                  ? null
                                  : "Incorrect Password";
                            },
                            controller: passwordTEC,
                            style: simpleTextStyle(),
                            decoration: new InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(
                                    color: Colors.black54, fontSize: 18),
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CupertinoColors.black),
                                  borderRadius: BorderRadius.circular(40),
                                ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
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
                    height: 8,
                  ),
                  MaterialButton(
                    onPressed: () {
                      signIn();
                    },
                    color: Colors.blue,
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    textColor: Colors.white,
                    splashColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    elevation: 4,
                    child: Text("Sign in"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
