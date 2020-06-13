import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/widgets/widget.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool hidePassword = true;
  bool passwordReset = false;
  String error;

  TextEditingController passwordTEC = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  changePassword() async {
    print("called");
    try {
      if (formKey.currentState.validate()) {
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        user.updatePassword(passwordTEC.text).then((val) {
          setState(() {
            passwordReset = true;
          });
        }).catchError((err) {
          setState(() {
            error = err.message;
          });
        });
      }
    } catch (e) {
      setState(() {
        print(error);
        error = e.message;
      });
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
    } else if (passwordReset) {
      return Container(
        color: Colors.teal,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.verified_user),
            ),
            Expanded(
              child: Text(
                "Password changed successfully!",
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    passwordReset = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
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
          )),
          child: Center(
            child: Container(
              height: 370,
              width: 370,
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
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Change Password",
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      showAlert(),
                      SizedBox(
                        height: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                            key: formKey,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextFormField(
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
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.circular(40),
                                      ))),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          MaterialButton(
                            onPressed: () {
                              changePassword();
                            },
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 90),
                            textColor: Colors.black,
                            splashColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 4,
                            child: Text("Sign in"),
                          ),
                        ],
                      )
                    ],
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
