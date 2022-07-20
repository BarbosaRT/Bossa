import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final fileController = context.watch<FileNotifier>();
    final themeController = context.watch<ThemeNotifier>();
    
    TextStyle? headline1 = themeController.textTheme.headline1; 
    

    return TextField(
      textAlign: TextAlign.center,
      textAlignVertical:
          TextAlignVertical.bottom,
      decoration: InputDecoration(
          // border: OutlineInputBorder(),
          border: InputBorder.none,
          hintText: "Title",
          hintStyle: headline1,
          contentPadding:
              const EdgeInsets.symmetric(
                  vertical: -5)),
      style: headline1,
      onChanged: (v) {
        fileController.titleSave(v);
      },
    );
  }
}