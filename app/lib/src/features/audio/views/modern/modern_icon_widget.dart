import 'dart:io';

import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModernIconWidget extends StatelessWidget {
  const ModernIconWidget({super.key});

  @override
  Widget build(BuildContext context) {    
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final AudioNotifier audioController = context.watch<AudioNotifier>();

    return 
      Positioned(
        top: screenHeight * 0.15,
        // 150 -> Size of the icon
        left: (screenWidth - screenWidth * 0.9) / 2,
        right: (screenWidth - screenWidth * 0.9) / 2,
        height: screenWidth * 0.9,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: FileImage(
              File(audioController.songs[audioController.index][2]),
            ),
            fit: BoxFit.cover,
          )),
        ),
      );
  }
}