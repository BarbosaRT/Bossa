import 'package:flutter/material.dart';

class AppColors {
  Color get backgroundColor => const Color.fromRGBO(30, 30, 30, 1);
  Color get backgroundAccent => const Color.fromRGBO(50, 50, 50, 1);

  Color accentColor = const Color.fromARGB(255, 0, 0, 255);

  Color get contrastColor => const Color.fromRGBO(255, 255, 255, 1);
  Color get contrastAccent => const Color.fromRGBO(220, 220, 220, 1);

  @override
  bool operator ==(covariant AppColors other) {
    if (identical(this, other)) return true;

    return false;
  }

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      backgroundAccent.hashCode ^
      contrastAccent.hashCode ^
      contrastColor.hashCode;
}

class DarkTheme extends AppColors {}

class LightTheme extends AppColors {
  @override
  get backgroundColor => const Color.fromRGBO(255, 255, 255, 1);

  @override
  get backgroundAccent => const Color.fromRGBO(220, 220, 220, 1);

  @override
  get contrastColor => const Color.fromRGBO(100, 100, 100, 1);

  @override
  get contrastAccent => const Color.fromRGBO(120, 120, 120, 1);
}

class Themes {
  List<AppColors> themes = [DarkTheme(), LightTheme()];

  int indexOf(dynamic element) {
    int output = -1;
    for (int index = 0; index < themes.length; index++) {
      if (themes[index].runtimeType == element.runtimeType) {
        output = index;
        break;
      }
    }
    return output;
  }
}

class AccentColors {
  static Color blueAccent = const Color.fromARGB(255, 0, 0, 255);
  static Color yellowAccent = const Color.fromARGB(255, 254, 221, 0);
  static Color greenAccent = const Color.fromARGB(255, 0, 151, 57);
  static Color purpleAccent = const Color.fromARGB(255, 125, 0, 204);
  static Color pinkAccent = const Color.fromARGB(255, 255, 0, 204);

  List<Color> listOfColors = [
    greenAccent,
    yellowAccent,
    blueAccent,
    purpleAccent,
    pinkAccent,
  ];
}
