import 'package:flutter/material.dart';

class InAppNotificationProvider with ChangeNotifier {
  bool _hasNotification = false;

  bool get hasNotification {
    return _hasNotification;
  }

  set hasNotification(bool value) {
    _hasNotification = value;
    notifyListeners();
  }
}
