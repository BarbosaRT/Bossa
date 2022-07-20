import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthorWidget extends StatelessWidget {
  const AuthorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final fileController = context.watch<FileNotifier>();
    final themeController = context.watch<ThemeNotifier>();
    
    TextStyle? headline2 = themeController.textTheme.headline2;

    return TextField(
      textAlign: TextAlign.center,
      textAlignVertical:
          TextAlignVertical.top,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Author",
        hintStyle: headline2,
      ),
      style: headline2,
      onChanged: (v) {
        fileController.authorSave(v);
      },
    );
  }
}