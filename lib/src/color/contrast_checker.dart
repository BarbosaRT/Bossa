import 'package:contrast_checker/contrast_checker.dart';
import 'package:flutter/material.dart';

class ContrastCheck {
  bool contrastCheck(Color firstColor, Color secondColor) {
    return ContrastChecker()
        .contrastCheck(10, firstColor, secondColor, WCAG.AAA);
  }
}
