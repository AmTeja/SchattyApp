import 'package:flutter/material.dart';
import 'package:schatty/helper/preferencefunctions.dart';

class DarkThemeProvider with ChangeNotifier {
  bool _darkTheme = false;

  bool get darkTheme {
    return _darkTheme;
  }

  set darkTheme(bool value) {
    _darkTheme = value;
    Preferences.saveThemePreference(value);
    notifyListeners();
  }
}
