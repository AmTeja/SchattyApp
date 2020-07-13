import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/widgets/widget.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String error;
  String profilePicURL =
      "https://www.searchpng.com/wp-content/uploads/2019/02/Deafult-Profile-Pitcher.png";

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Constants constants = new Constants();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController rePasswordTEC = new TextEditingController();

  bool userNameExists = false;
  bool isLoading = false;
  bool verificationSent = false;
  bool hidePassword = true;

  signUp() async {
    error = null;
    if (formKey.currentState.validate() &&
        (passwordTEC.text == rePasswordTEC.text)) {
      setState(() {
        isLoading = true;
      });
      try {
        databaseMethods.getUserByUserName(userNameTEC.text).then((val) {
          if (val != null) {
            print("Already Exists");
            userNameExists = true;
          }
        });
        if (!userNameExists) {
          FirebaseAuth _auth = FirebaseAuth.instance;
          AuthResult result = await _auth.createUserWithEmailAndPassword(
              email: emailTEC.text, password: passwordTEC.text);
          FirebaseUser firebaseUser = result.user;
          if (firebaseUser != null) {
            Map<String, String> userInfoMap = {
              //Making MAP for firebase
              "username": userNameTEC.text.toLowerCase(),
              "displayName": userNameTEC.text,
              "email": emailTEC.text,
              "searchKey": userNameTEC.text.substring(0, 1).toUpperCase(),
              "photoURL": profilePicURL,
              "uid": firebaseUser.uid,
              "usernameIndex": await makeIndex(),
            };
            String uid = firebaseUser.uid;
            databaseMethods.uploadUserInfo(userInfoMap, uid);
            await firebaseUser.sendEmailVerification().then((value) => {
              setState(() {
                error = null;
                verificationSent = true;
                isLoading = false;
              })
            });
          }
        } else {
          setState(() {
            isLoading = false;
            error = "Username already exists";
            userNameExists = false;
          });
        }
      } catch (e) {
        print(e);
        error = await e.message;
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error = "Passwords do not match!";
        isLoading = false;
      });
    }
  }

  makeIndex() {
    try {
      print('Called');
      List<String> indexList = [];
      for (int i = 0; i < userNameTEC.text.length; i++) {
        for (int y = 0; y < userNameTEC.text.length + 1; y++) {
          indexList.add(userNameTEC.text.substring(0, y).toLowerCase());
        }
      }
      return indexList;
    } catch (e) {
      print('Error making index: $e');
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
    return SizedBox(height: 0,);
  }

  Widget showVerification() {
    if (verificationSent) {
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
                "Verification Email Sent!",
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    verificationSent = false;
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final focus = FocusNode();
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? loadingScreen("Signing you in")
          : Container(
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            bottom: true,
            left: true,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.75,
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
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Join Us",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                              ),
                      ),
                    ),
                    showErrorAlert(),
                    showVerification(),
                    SizedBox(height: 30,),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: UserNameValidator.validate,
                                  controller: userNameTEC,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 15),
                                      labelText: "Username",
                                      labelStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                      border: new OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                  borderSide:
                                  BorderSide(color: Colors.white),
                                )),
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(

                            validator: EmailValidator.validate,
                            controller: emailTEC,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            decoration: new InputDecoration(
                                contentPadding: EdgeInsets.only(left: 15),
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(),
                                )),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: hidePassword,
                            validator: PasswordValidator.validate,
                            controller: passwordTEC,
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
                                contentPadding: EdgeInsets.only(left: 15),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(),
                                )),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            focusNode: focus,
                            obscureText: hidePassword,
                            validator: (val) {
                              return passwordTEC.text.isNotEmpty
                                  ? null
                                  : "Password cannot be empty";
                            },
                            controller: rePasswordTEC,
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
                                contentPadding: EdgeInsets.only(left: 15),
                                labelText: "Re-Enter Password",
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(),
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    MaterialButton(
                      onPressed: () {
                        signUp();
                      },
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: 20, horizontal: 90),
                      textColor: Colors.black,
                      splashColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      elevation: 4,
                      child: Text("Sign Up"),
                    ),
                    SizedBox(height: error != null ? 20 : 120,)
                  ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
