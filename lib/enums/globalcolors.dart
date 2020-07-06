import 'package:flutter/material.dart';

class GlobalColors {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
//      primaryColor: isDarkTheme ? Color(0xff111111) : Color(0xff51cec0),

      primaryColor: isDarkTheme ? Color(0xff111111) : Colors.white,

      backgroundColor: isDarkTheme ? Color(0xff111111) : Color(0xffeeefe1),

      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),

      hintColor: isDarkTheme ? Colors.white : Colors.grey,

      highlightColor: isDarkTheme ? Colors.grey : Color(0xff51cec0),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Colors.grey,
      splashColor: isDarkTheme ? Colors.white : Colors.black,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 141, 133, 133),
      ),
      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      textSelectionColor: isDarkTheme ? Colors.grey : Colors.black,
      cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
      ),

      //Fonts
//      textTheme: GoogleFonts.robotoSlabTextTheme(
//        Theme.of(context).textTheme,
//      ),
    );
  }
}
