import 'package:flutter/cupertino.dart';
import 'package:schatty/enums/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState viewState = ViewState.IDLE;

  ViewState get getViewState => viewState;

  void setToLoading() {
    viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setToIdle() {
    viewState = ViewState.IDLE;
    notifyListeners();
  }
}
