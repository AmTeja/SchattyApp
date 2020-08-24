import 'package:flutter/material.dart';

class CurrentChatUser with ChangeNotifier {
  String _currentUser = "";

  String get currentUser {
    return _currentUser;
  }

  set currentUser(String username) {
    _currentUser = username;
    notifyListeners();
  }
}
