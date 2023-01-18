import 'package:flutter/widgets.dart';

class SettingsController extends ChangeNotifier {
  bool _gradientOnPlayer = true;
  bool get gradientOnPlayer => _gradientOnPlayer;

  bool _cropImages = true;
  bool get cropImages => _cropImages;

  void setGradientOnPlayer(bool newValue) {
    _gradientOnPlayer = newValue;
    notifyListeners();
  }

  void setCropImages(bool newValue) {
    _cropImages = newValue;
    notifyListeners();
  }
}
