import 'package:flutter/foundation.dart';

enum SplashState {waiting, finished}

class SplashNotifier extends ChangeNotifier{
  SplashState _splashState = SplashState.waiting;
  SplashState get splashState => _splashState;
 

  void finishSplash(){
    _splashState = SplashState.finished;
    notifyListeners();
  }

}