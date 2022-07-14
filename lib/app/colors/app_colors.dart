import 'package:flutter/material.dart';

class AppTheme {
  bool isDark = false;

  ThemeData get themeData {
    Color lightBackground = const Color.fromARGB(255, 220, 220, 220);
    Color lightBackground2 = const Color.fromARGB(255, 200, 200, 200);

    Color lightAccent = const Color.fromARGB(255, 250, 250, 250);
    Color lightAccent2 = const Color.fromARGB(255, 230, 230, 230);

    Color darkBackground = const Color.fromARGB(255, 10, 10, 10);
    Color darkAccent = const Color.fromARGB(255, 50, 50, 50);
    Color darkAccent2 = const Color.fromARGB(255, 30, 30, 30);

    Color primaryColor = const Color.fromARGB(255, 0, 30, 255);

    TextTheme originalTheme =
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;

    TextTheme txtTheme =
        (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
              headline1: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Avenir',
                  color: originalTheme.bodyText1!.color,
                  fontWeight: FontWeight.bold),
              headline2: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Avenir',
                  color: originalTheme.bodyText2!.color,
                  fontWeight: FontWeight.bold),
              headline3: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Avenir',
                  color: originalTheme.bodyText1!.color,
                  fontWeight: FontWeight.bold),
              headline4: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Avenir',
                  color: originalTheme.bodyText2!.color,
                  fontWeight: FontWeight.normal),
            );
    Color? txtColor = txtTheme.bodyText1!.color;
    ColorScheme colorScheme = ColorScheme(
        // Decide how you want to apply your own custom them, to the MaterialApp
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: isDark ? lightAccent : darkAccent,
        secondary: isDark ? lightBackground : darkBackground,
        background: isDark ? darkBackground : lightBackground,
        surface: lightBackground2,
        onBackground: isDark ? lightBackground2 : darkBackground,
        onSurface: txtColor!,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red.shade400);

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    var t = ThemeData.from(textTheme: txtTheme, colorScheme: colorScheme)
        // We can also add on some extra properties that ColorScheme seems to miss
        .copyWith(
            primaryColor: primaryColor,
            cardColor: isDark ? darkAccent : lightAccent,
            canvasColor: isDark ? darkAccent2 : lightAccent2,
            backgroundColor: isDark ? darkBackground : lightBackground);

    /// Return the themeData which MaterialApp can now use
    return t;
  }
}
