import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar();
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.black26,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.blue,
      )),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.black,
      )));
}

TextStyle simpleTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 18,
  );
}

TextStyle mediumTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 18,
  );
}

// ignore: non_constant_identifier_names
Widget SchattyIcon() {
  return Image(
    image: AssetImage('assets/icon/icon.png'),
  );
}

Widget loadingScreen(String text) {
  return Scaffold(
    body: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: LinearProgressIndicator(
                backgroundColor: Colors.black,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
