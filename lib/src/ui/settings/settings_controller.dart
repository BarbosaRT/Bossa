import 'package:flutter/widgets.dart';

class SettingsController extends ChangeNotifier {
  bool _gradient = true;
  bool get gradient => _gradient;

  void setGradientOnPlayer(bool newValue) {
    _gradient = newValue;
    notifyListeners();
  }
}
