import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTabs extends StatelessWidget {
  final String text;

  const AppTabs({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();

    Color backgroundColor = themeController.themeData.cardColor;
    TextStyle? textStyle = themeController.textTheme.headline3;

    return Container(
      width: 110,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 0),
            )
          ]),
      child: Text(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
