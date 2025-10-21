import 'package:bossa/src/color/app_colors.dart';
import 'package:flutter/material.dart';

class ColorController extends ChangeNotifier {
  AppColors _currentTheme = DarkTheme();
  AppColors get currentTheme => _currentTheme;

  Color _currentAccent = AccentColors.blueAccent;
  Color get currentAccent => _currentAccent;

  MaterialColor _currentCustomColor = Colors.blue;
  MaterialColor get currentCustomColor => _currentCustomColor;

  void changeTheme(AppColors newTheme) {
    _currentTheme = newTheme;
    _currentTheme.accentColor = _currentAccent;
    notifyListeners();
  }

  void changeAccentColor(Color newColor) {
    _currentAccent = newColor;
    Map<int, Color> color = {
      50: _currentAccent.withValues(alpha: .1),
      100: _currentAccent..withValues(alpha: .2),
      200: _currentAccent..withValues(alpha: .3),
      300: _currentAccent..withValues(alpha: .4),
      400: _currentAccent..withValues(alpha: .5),
      500: _currentAccent..withValues(alpha: .6),
      600: _currentAccent..withValues(alpha: .7),
      700: _currentAccent..withValues(alpha: .8),
      800: _currentAccent..withValues(alpha: .9),
      900: _currentAccent..withValues(alpha: 1),
    };
    // ignore: deprecated_member_use
    _currentCustomColor = MaterialColor(_currentAccent.value, color);

    changeTheme(currentTheme);
  }
}
