import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/helper/helperfunctions.dart';
import 'package:schatty/services/auth.dart';
import 'package:schatty/services/database.dart';
import 'package:schatty/views/chatsroom.dart';
import 'package:schatty/widgets/widget.dart';

class SignUp extends StatefulWidget {

  final Function toggle;

  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Constants constants = new Constants();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  signUP()
  {
    print("SignUP Called");
    if(formKey.currentState.validate()){
      Map<String, String> userInfoMap = {
        "username": userNameTEC.text,
        "email": emailTEC.text
      };

      HelperFunctions.saveUserEmailSharedPreference(emailTEC.text);
      HelperFunctions.saveUserNameSharedPreference(userNameTEC.text);
      print("saved");
      setState(() {
        isLoading = true;
      });

      authMethods.signUpWithEmailAndPassword(emailTEC.text, passwordTEC.text)
          .then((val) {
        // print("$val");


        databaseMethods.uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        print("Saved");
        constants.setFirstTime(false);
        print(constants.getFirstTime());
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ChatRoom(

            )
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Container(
        child: Center(
          child: CircularProgressIndicator(
          ),
        ),
      ) : SafeArea(
        bottom: true,
        left: true,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage("assets/images/registerbg.png"),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
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
                            return val.isEmpty ||
                                (val.length < 5 || val.length > 17)
                                ? "Please enter a valid user name (Length between 5 and 18)"
                                : null;
                          },
                          controller: userNameTEC,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("Username"),
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
                            decoration: textFieldInputDecoration("Email")
                        ),
                        TextFormField(
                            obscureText: true,
                            validator: (val) {
                              return val.length > 6
                                  ? null
                                  : "Please use a password with more than 6 characters.";
                            },
                            controller: passwordTEC,
                            style: simpleTextStyle(),
                            decoration: textFieldInputDecoration("Password")
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                  SizedBox(height: 8,),
                        MaterialButton(
                          onPressed: () {
                            signUP();
                    },
                    color: Colors.blue,
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    textColor: Colors.white,
                    splashColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    elevation: 4,
                    child: Text(
                        "Sign Up"
                    ),
                  ),
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
                      Text("Already an user? ", style: mediumTextStyle(),),
                      GestureDetector(
                        onTap: () {
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("Login here", style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              decoration: TextDecoration.underline
                          ),),
                        ),
                      ),
                      Text("!", style: mediumTextStyle(),)
                    ],
                  )
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
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChatRoom()
      ));
    });
  }
}
