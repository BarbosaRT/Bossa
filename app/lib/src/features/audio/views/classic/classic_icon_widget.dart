import 'dart:io';

import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassicIconWidget extends StatelessWidget {
  const ClassicIconWidget({super.key});

  @override
  Widget build(BuildContext context) {    
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color canvasColor = themeController.themeData.canvasColor;

    return Positioned(
      top: screenHeight * 0.15,
      // 150 -> Size of the icon
      left: (screenWidth - screenWidth * 0.7) / 2,
      right: (screenWidth - screenWidth * 0.7) / 2,
      height: screenHeight / 3,
      child: Container(
        decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: canvasColor,
              width: 2,
            )),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: canvasColor,
                  width: 3,
                ),
                image: DecorationImage(
                  image: FileImage(
                    File(audioController.songs[audioController.index][2]),
                  ),
                  fit: BoxFit.cover,
                )),
          ),
        ),
      ));
  }
}