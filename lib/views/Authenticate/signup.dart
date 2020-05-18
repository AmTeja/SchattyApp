import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
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

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Constants constants = new Constants();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  signUP() {
    if (formKey.currentState.validate()) {
      Map<String, String> userInfoMap = {
        "username": userNameTEC.text,
        "email": emailTEC.text,
        "searchKey": userNameTEC.text.substring(0, 1).toUpperCase(),
      };

      HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
      HelperFunctions.saveUserNameSharedPreference(userNameTEC.text);
      setState(() {
        isLoading = true;
      });

      authMethods
          .signUpWithEmailAndPassword(emailTEC.text, passwordTEC.text)
          .then((val) {
        // print("$val");

        databaseMethods.uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        print("Saved");
        constants.setFirstTime(false);
        print(constants.getFirstTime());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    passwordTEC.addListener(() {
//      setState(() {
//        eightChars = passwordTEC.text.length >= 8;
//        number = passwordTEC.text.contains(RegExp(r'\d'), 0);
//        upperCaseChar = passwordTEC.text.contains((new RegExp(r'[A-Z]')), 0);
//        specialChar = passwordTEC.text.isNotEmpty &&
//            !passwordTEC.text.contains(RegExp(r'^[\w&.-]+$'), 0);
//      });
//    });
  }

  bool ifAllValid() {
    return eightChars && number && specialChar && upperCaseChar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                bottom: true,
                left: true,
                child: Center(
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
                                  return val.isEmpty ||
                                          (val.length < 5 || val.length > 17)
                                      ? "Please enter a valid user name (Length between 5 and 18)"
                                      : null;
                                },
                                controller: userNameTEC,
                                style: simpleTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Username",
                                    labelStyle: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
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
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
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
                          height: 16,
                        ),
                        MaterialButton(
                          onPressed: () {
                            signUP();
                          },
                          color: Colors.blue,
                          minWidth: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          textColor: Colors.white,
                          splashColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                          elevation: 4,
                          child: Text("Sign Up"),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
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
