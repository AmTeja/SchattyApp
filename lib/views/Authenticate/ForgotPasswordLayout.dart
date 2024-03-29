import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/services/DatabaseManagement.dart';
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
  bool emailSent = false;

  String error;

  resetPassword() async {
    try {
      if (formKey.currentState.validate()) {
        setState(() {
          isLoading = true;
        });
        await _firebaseAuth.sendPasswordResetEmail(email: emailTEC.text);
        setState(() {
          isLoading = false;
          emailSent = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.message;
      });
    }
  }

  Widget showErrorAlert() {
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
              child: Text(
                error,
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
    return SizedBox(
      height: 0,
    );
  }

  Widget showEmailSent() {
    if (emailSent) {
      return Container(
        color: Colors.teal,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check),
            ),
            Expanded(
              child: Text(
                "Reset Email Sent!",
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    emailSent = false;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Scaffold(
            backgroundColor: Colors.black,
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
          alignment: Alignment.center,
          child: Container(
            width: 370,
            height: 400,
            decoration: BoxDecoration(
              boxShadow: [
                new BoxShadow(
                    color: Color.fromARGB(217, 0, 0, 0),
                    offset: new Offset(2, 3),
                    blurRadius: 3,
                    spreadRadius: 4)
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
                  padding: EdgeInsets.only(bottom: 0, top: 20),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                showErrorAlert(),
                showEmailSent(),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      TextFormField(
                          validator: (val) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val)
                                      ? null
                                      : "Please enter a valid e-mail ID.";
                                },
                                controller: emailTEC,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                MaterialButton(
                  onPressed: () {
                    resetPassword();
                  },
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 90),
                  textColor: Colors.black,
                  splashColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  elevation: 4,
                  child: Text("Send Reset Email"),
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
        ),
      ),
    ) : Scaffold(
      backgroundColor: Colors.black,
      body: loadingScreen("Sending email!"),
    );
  }
}
