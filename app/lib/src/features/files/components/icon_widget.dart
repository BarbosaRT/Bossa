import 'dart:io';

import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IconWidget extends StatelessWidget {
  const IconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final fileController = context.watch<FileNotifier>();
    final themeController = context.watch<ThemeNotifier>();
    
    double screenHeight = MediaQuery.of(context).size.height;
    Color widgetColor = themeController.themeData.cardColor;         
    Color? iconColor = themeController.textTheme.headline2!.color;

    return GestureDetector(
        onTap: fileController.iconSave,
        child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              color: widgetColor,
            ),
            height: screenHeight * 0.4,
            width: screenHeight * 0.4,
            margin: EdgeInsets.symmetric(
                horizontal:
                    screenHeight * 0.05),
            child: ((fileController.iconPath == '')
                ? Icon(
                    Icons.music_note,
                    size: screenHeight * 0.3,
                    color: iconColor,
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(20),
                        image: DecorationImage(
                            image: FileImage(File(
                                fileController.iconPath))))))),
      );
  }
}