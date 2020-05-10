import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schatty/widgets/widget.dart';

class SignIn extends StatefulWidget {

  final Function toggle;

  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: appBarMain(context),
      body: Container(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: simpleTextStyle(),
                decoration: textFieldInputDecoration("Email")
              ),
              TextField(
                style: simpleTextStyle(),
                decoration: textFieldInputDecoration("Password")
              ),
              SizedBox(height: 8,),
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Forgot Password?", style: simpleTextStyle(),),
                ),
              ),
              SizedBox(height: 8,),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff007EF4),
                      const Color(0xff2A75BC)
                    ]
                  ),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Text("Sign In", style: mediumTextStyle()),
              ),
              SizedBox(height: 16,),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: Text('Sign In With Google',style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),),
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
                          color: Colors.white,
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
}
