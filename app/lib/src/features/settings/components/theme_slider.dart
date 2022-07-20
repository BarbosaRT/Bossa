import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSlider extends StatelessWidget {
  const ThemeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();
    

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Switch Theme',
          style: themeController.textTheme.headline3!,
        ),
        Switch(
            value: themeController.isDark,
            onChanged: (value) {
              themeController.changeTheme(value);
            }),
      ],
    );
  }
}
