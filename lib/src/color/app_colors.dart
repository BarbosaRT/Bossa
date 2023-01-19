import 'package:flutter/material.dart';

class AppColors {
  Color backgroundColor;
  Color backgroundAccent;
  Color accentColor;
  Color contrastColor;
  Color contrastAccent;

  AppColors({
    this.backgroundColor = const Color.fromRGBO(30, 30, 30, 1),
    this.backgroundAccent = const Color.fromRGBO(50, 50, 50, 1),
    this.accentColor = const Color.fromARGB(255, 0, 0, 255),
    this.contrastColor = const Color.fromRGBO(255, 255, 255, 1),
    this.contrastAccent = const Color.fromRGBO(220, 220, 220, 1),
  });
}
