import 'package:flutter/cupertino.dart';


class ImageChangeProvider with ChangeNotifier{
  bool _profileUpdate = false;

  bool get profileUpdate{
    return _profileUpdate;
  }

  set profileUpdate(bool value){
    _profileUpdate = value;
    notifyListeners();
  }

}