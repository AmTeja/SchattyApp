import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/views/chatsroom.dart';
import 'package:schatty/views/forgetpassword.dart';
import 'package:schatty/widgets/widget.dart';

class SignIn extends StatefulWidget {

  final Function toggle;

  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final formKey = GlobalKey<FormState>();

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: ['email']);

  QuerySnapshot snapshotUserInfo;

  bool isLoading = false;
  bool correctPass = false;

  signIn() {
    correctPass = true;
    if (formKey.currentState.validate()) {
      print("Validated");
      HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
      setState(() {
        isLoading = true;
      });

      databaseMethods.getUserByUserEmail(emailTEC.text).then((value) {
        snapshotUserInfo = value;
        HelperFunctions
            .saveUserNameSharedPreference(
            snapshotUserInfo.documents[0].data["username"]);
      });

      authMethods.signInWithEmailAndPassword(emailTEC.text, passwordTEC.text)
          .then((value) {
        if (value != null) {
          correctPass = true;
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          print("Logged In true");
          Navigator.pushReplacement(context, MaterialPageRoute(
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
    correctPass = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBarMain(context),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ExactAssetImage("assets/images/loginbg.png"),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        decoration: textFieldInputDecoration("Email")
                    ),
                    TextFormField(
                        obscureText: true,
                        validator: (val) {
                          return passwordTEC.text.length >= 8 ? null
                              : "Incorrect Password";
                        },
                        controller: passwordTEC,
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration("Password")
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ForgotPassword()
                  ));
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Forgot Password?", style: simpleTextStyle(),),
                  ),
                ),
              ),
              SizedBox(height: 8,),
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
                child: Text(
                    "Sign in"
                  ),
                ),
//
              SizedBox(height: 16,),
              MaterialButton(
                onPressed: () {
                  signInWithGoogle();
                },
                color: Colors.white,
                minWidth: MediaQuery
                    .of(context)
                    .size
                    .width,
                textColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding: EdgeInsets.symmetric(vertical: 20),
                splashColor: Colors.blue,
                elevation: 4,
                child: Text("Sign in with Google"),

              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not an user? ", style: mediumTextStyle(),),
                  GestureDetector(
                    onTap: () {
                      widget.toggle();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("Join us now!", style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          decoration: TextDecoration.underline
                      ),),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void signInWithGoogle() {
    authMethods.signInWithGoogle().whenComplete(() {
      String username = authMethods.googleSignIn.currentUser.displayName;
      HelperFunctions.saveUserNameSharedPreference(username);
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChatRoom()
      ));
    });
  }
}
