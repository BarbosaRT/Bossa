import 'package:flutter/material.dart';

class AppColors {
  Color accentColor;
  Color backgroundColor;
  Color contrastColor;

  AppColors({
    this.accentColor = const Color.fromRGBO(0, 35, 120, 1),
    this.backgroundColor = const Color.fromRGBO(30, 30, 30, 1),
    this.contrastColor = const Color.fromRGBO(255, 255, 255, 1),
  });
}
