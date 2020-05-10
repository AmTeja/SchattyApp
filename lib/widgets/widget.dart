import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context)
{
  return AppBar(
    title: Image.asset("assets/images/logo.png", height: 50,),
  );
}

InputDecoration textFieldInputDecoration(String hintText)
{
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.black,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue,
          )
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          )
      )
  );
}

TextStyle simpleTextStyle()  {
  return TextStyle(
    color: Colors.black,
    fontSize: 16,
  );
}

TextStyle mediumTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 18,
  );
}