import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool isLoading = false;
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;

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

  signUP() async {
    await FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        profilePicURL = user.photoUrl;
      });
    }).catchError((onError) {
      print(onError);
    });
    if (formKey.currentState.validate() &&
        (passwordTEC.text == rePasswordTEC.text)) {
      authMethods
          .signUpWithEmailAndPassword(emailTEC.text, passwordTEC.text)
          .then((val) {
        print("$val");
        Map<String, String> userInfoMap = { //Making MAP for firebase
          "username": userNameTEC.text,
          "email": emailTEC.text,
          "searchKey": userNameTEC.text.substring(0, 1).toUpperCase(),
//          "uid":  authMethods.getUserUID(),
          "photoUrl": profilePicURL
        };

        databaseMethods.uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      });

      //Check for password match


      HelperFunctions.saveUserEmailSharedPreference(
          emailTEC.text); //Saving username and email cache on device
      HelperFunctions.saveUserNameSharedPreference(userNameTEC.text);
      setState(() {
        isLoading = true;
      });

    } else {
      Fluttertoast.showToast(msg: "Password do not match!");
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
      backgroundColor: Colors.black,
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
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
                          Container(
                            padding: EdgeInsets.only(
                              right: 140, bottom: 39,),
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Join Us",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                              ),
                            ),
                          ),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                    validator: (val) {
                                      return val.isEmpty ||
                                              (val.length < 5 ||
                                                  val.length > 17)
                                          ? "Please enter a valid user name (Length between 5 and 18)"
                                          : null;
                                    },
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
                                  obscureText: true,
                                  validator: (val) {
                                    return passwordTEC.text.length > 8
                                        ? null
                                        : "Please use a password with more than 8 characters";
                                  },
                                  controller: passwordTEC,
                                  style: simpleTextStyle(),
                                  decoration: new InputDecoration(
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
                                  obscureText: true,
                                  validator: (val) {
                                    return passwordTEC.text.length > 8
                                        ? null
                                        : "Please use a password with more than 8 characters";
                                  },
                                  controller: rePasswordTEC,
                                  style: simpleTextStyle(),
                                  decoration: new InputDecoration(
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
                              signUP();
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
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "OR",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            onPressed: () {
                              signInWithGoogle();
                            },
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 60),
                            textColor: Colors.black,
                            splashColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            elevation: 4,
                            child: Text("Signup With Google"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
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
      HelperFunctions.saveUserNameSharedPreference(username);
      HelperFunctions.saveUserLoggedInSharedPreference(true);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatRoom()));
    });
  }
}
