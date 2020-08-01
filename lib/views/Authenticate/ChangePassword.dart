import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool hidePassword = true;
  bool passwordReset = false;
  String error;

  TextEditingController newPasswordTEC = new TextEditingController();
  TextEditingController oldPasswordTEC = new TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  DatabaseMethods databaseMethods = new DatabaseMethods();
  final formKey = GlobalKey<FormState>();

  changePassword() async {
    print("called");
    try {
      if (formKey.currentState.validate()) {
        FirebaseUser user = await auth.currentUser();
        AuthResult result = await auth.signInWithEmailAndPassword(
            email: user.email, password: oldPasswordTEC.text);
        FirebaseUser oldUser = result.user;
        if (oldUser != null) {
          user.updatePassword(newPasswordTEC.text).then((val) {
            setState(() {
              passwordReset = true;
            });
          }).catchError((err) {
            setState(() {
              error = err.message;
            });
          });
        }
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
      appBar: AppBar(
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.2),
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      "Change Password",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  showAlert(),
                  SizedBox(
                    height: 40,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: TextFormField(
                              obscureText: hidePassword,
                              validator: PasswordValidator.validate,
                              controller: oldPasswordTEC,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              decoration: new InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(Icons.remove_red_eye),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 15, top: 20, bottom: 20),
                                  labelText: "Old Password",
                                  border: new OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(40),
                                  ))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                              obscureText: hidePassword,
                              validator: PasswordValidator.validate,
                              controller: newPasswordTEC,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              decoration: new InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(Icons.remove_red_eye),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 15, top: 20, bottom: 20),
                                  labelText: "New Password",
                                  border: new OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(40),
                                  ))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: MaterialButton(
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
                            child: Text("Change Password"),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
