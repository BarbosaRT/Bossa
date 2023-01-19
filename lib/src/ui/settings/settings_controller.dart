import 'package:flutter/widgets.dart';

class SettingsController extends ChangeNotifier {
  bool _gradientOnPlayer = true;
  bool get gradientOnPlayer => _gradientOnPlayer;

  void setGradientOnPlayer(bool newValue) {
    _gradientOnPlayer = newValue;
    notifyListeners();
  }
}
