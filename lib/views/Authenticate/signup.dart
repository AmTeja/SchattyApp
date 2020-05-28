import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/preferencefunctions.dart';
import 'package:schatty/services/AuthenticationManagement.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/MainChatsRoom.dart';
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
              "username": userNameTEC.text,
              "email": emailTEC.text,
              "searchKey": userNameTEC.text.substring(0, 1).toUpperCase(),
              "photoUrl": profilePicURL
            };
            databaseMethods.uploadUserInfo(userInfoMap);
            await firebaseUser.sendEmailVerification().then((value) => {
                  setState(() {
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
        setState(() {
          isLoading = false;
          error = e.message;
        });
      }
    } else {
      setState(() {
        error = "Passwords do not match!";
        isLoading = false;
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? loadingScreen()
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
                width: 370,
                height: 700,
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
                        padding: EdgeInsets.only(
                          right: 140, top: 40,),
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Join Us",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
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
                              validator: NameValidator.validate,
                              controller: userNameTEC,
                              style: simpleTextStyle(),
                              decoration: new InputDecoration(
                                  contentPadding:
                                  EdgeInsets.only(left: 15),
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(40),
                                    borderSide:
                                    BorderSide(color: Colors.white),
                                  ))),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: EmailValidator.validate,
                            controller: emailTEC,
                            style: simpleTextStyle(),
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
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: hidePassword,
                            validator: (val) {
                              return passwordTEC.text.isNotEmpty
                                  ? null
                                  : "Password cannot be empty";
                            },
                            controller: rePasswordTEC,
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
                    Flexible(
                      fit: FlexFit.loose,
                      child: MaterialButton(
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

  void signInWithGoogle() {
    authMethods.signInWithGoogle().whenComplete(() {
      String username = authMethods.googleSignIn.currentUser.displayName;
      HelperFunctions.saveUserNameSharedPreference(
          username.replaceAll(" ", "_"));
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
    });
  }
}
