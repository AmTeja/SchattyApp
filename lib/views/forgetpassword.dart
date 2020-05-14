import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:schatty/helper/authenticate.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/widgets/widget.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailTEC = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isLoading = false;

  resetPassword() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await _firebaseAuth.sendPasswordResetEmail(email: emailTEC.text);
      Fluttertoast.showToast(
          msg: "Reset link sent to email!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Authenticate()));
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      backgroundColor: Color(0xfff0f2f2),
      body: Container(
        alignment: Alignment.center,
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
                        decoration: textFieldInputDecoration("Email")),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                alignment: Alignment.centerRight,
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                onTap: () {
                  resetPassword();
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xff007EF4),
                        const Color(0xff2A75BC)
                      ]),
                      borderRadius: BorderRadius.circular(30)),
                  child: Text("Reset", style: mediumTextStyle()),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
