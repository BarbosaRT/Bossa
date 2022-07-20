import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier{

  final Color _lightBackground = const Color.fromARGB(255, 220, 220, 220);
  final Color _lightColor = const Color.fromARGB(255, 200, 200, 200);

  final Color _lightCard = const Color.fromARGB(255, 250, 250, 250);
  final Color _lightCanvas = const Color.fromARGB(255, 230, 230, 230);

  final Color _darkBackground = const Color.fromARGB(255, 10, 10, 10);
  final Color _darkColor = const Color.fromARGB(255, 50, 50, 50);

  final Color _darkCard = const Color.fromARGB(255, 40, 40, 40);
  final Color _darkCanvas = const Color.fromARGB(255, 20, 20, 20);

  final Color _primaryColor = const Color.fromARGB(255, 0, 30, 255);

  bool _isDark = true;    
  bool get isDark => _isDark;        

  ThemeData _themeData = ThemeData();
  ThemeData get themeData => _themeData; 

  TextTheme _textTheme = const TextTheme(
    headline1: TextStyle(
      fontSize: 40,
      fontFamily: 'Avenir',
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(
      fontSize: 30,
      fontFamily: 'Avenir',
      fontWeight: FontWeight.bold,
    ),
    headline3: TextStyle(
      fontSize: 20,
      fontFamily: 'Avenir',
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      fontSize: 15,
      fontFamily: 'Avenir',
    ),
  );
  TextTheme get textTheme => _textTheme;
  ColorScheme _colorScheme = const ColorScheme.light();

  ThemeNotifier() {
    changeTheme(isDark);
  }

  // Changes the theme from dark mode to light mode
  void changeTheme(bool darkModeEnabled) { 
    _isDark = darkModeEnabled;
    _colorScheme = ColorScheme(
        // Decide how you want to apply your own custom them, to the MaterialApp
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: isDark ? _lightColor : _darkColor,
        secondary: isDark ? _lightBackground : _darkBackground,
        background: isDark ? _darkBackground : _lightBackground,
        surface: _lightColor,
        onBackground: isDark ? _lightColor : _darkColor,
        onSurface: Colors.white,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red.shade400);

    _themeData = ThemeData(
      primaryColorLight: _lightCard,
      primaryColorDark: _darkCard,
      backgroundColor: _isDark ? _darkBackground : _lightBackground,
      primaryColor: _primaryColor,
      cardColor: _isDark ? _darkCard : _lightCard,
      canvasColor: isDark ? _darkCanvas : _lightCanvas,
      buttonTheme: ButtonThemeData(colorScheme: _colorScheme)
    );

    _textTheme = (_isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
              headline1: _textTheme.headline1!.copyWith(color: _isDark ? _lightColor : _darkColor),
              headline2: _textTheme.headline2!.copyWith(color: _isDark ? _lightColor : _darkColor),
              headline3: _textTheme.headline3!.copyWith(color: _isDark ? _lightColor : _darkColor),
              headline4: _textTheme.headline4!.copyWith(color: _isDark ? _lightColor : _darkColor),
            );

    notifyListeners();
  }
}