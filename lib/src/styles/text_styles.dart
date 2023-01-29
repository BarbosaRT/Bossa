import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  final headline = GoogleFonts.poppins(
      color: Colors.amber, fontSize: 24, fontWeight: FontWeight.normal);

  final boldHeadline = GoogleFonts.poppins(
      color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold);

  final headline2 = GoogleFonts.poppins(
      color: Colors.amber, fontSize: 15, fontWeight: FontWeight.normal);

  final boldHeadline2 = GoogleFonts.poppins(
      color: Colors.amber, fontSize: 15, fontWeight: FontWeight.bold);

  final headline3 = GoogleFonts.poppins(
      color: Colors.amber, fontSize: 10, fontWeight: FontWeight.normal);

  Text getConstrainedTextByWidth({
    required TextStyle textStyle,
    required String text,
    required double textWidth,
  }) {
    var textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    var tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double fontSize = textStyle.fontSize == null ? 15 : textStyle.fontSize!;
    if (tp.width > textWidth) {
      final scale = tp.width / textWidth;
      fontSize /= scale;
    }
    if (fontSize < 10) {
      fontSize = 10;
      textSpan = TextSpan(
        text: text,
        style: textStyle.copyWith(fontSize: fontSize),
      );

      tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      var widthOfLetter = tp.width / text.length;
      final numberOfLetterToRemove = (tp.width - textWidth + 3) / widthOfLetter;
      text =
          '${text.substring(0, text.length - numberOfLetterToRemove.toInt())}...';
    }
    return Text(
      text,
      style: textStyle.copyWith(fontSize: fontSize),
    );
  }
}
