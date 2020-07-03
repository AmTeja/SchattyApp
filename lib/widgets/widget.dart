import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

compareTime(String timeInDM) {
  var time = timeInDM.split(':');
  int sentDay = int.parse(time[0]);
  int sentMonth = int.parse(time[1]);
  int sentYear = int.parse(time[2]);

  var currentTime = DateFormat('dd:M:y').format(DateTime.now()).split(':');
  int currentDay = int.parse(currentTime[0]);
  int currentMonth = int.parse(currentTime[1]);
  int currentYear = int.parse(currentTime[2]);

  if (currentYear >= sentYear) {
    if (currentMonth >= sentMonth) {
      if (currentDay > sentDay) {
        return true;
      }
      if (currentDay == sentDay) {
        return false;
      }
    }
  }
  return true;
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
