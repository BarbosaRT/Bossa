import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/audio/views/modern/modern_icon_widget.dart';
import 'package:bossa/src/features/audio/components/player_widget.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModernAudioPage extends StatelessWidget {
  const ModernAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    
    TextStyle? headline1 = themeController.textTheme.headline1;
    TextStyle? headline3 = themeController.textTheme.headline3;

    Color backgroundColor = themeController.themeData.backgroundColor;
    Color? iconColor = themeController.themeData.primaryColorLight;
    Color primaryColor = themeController.themeData.primaryColor;

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            // Background
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        primaryColor,
                        backgroundColor,
                        backgroundColor,
                      ])),
                )),
            // Appbar
            Positioned(
                top: screenHeight * 0.02,
                left: 0,
                right: 0,
                child: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      audioController.stop();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    color: iconColor,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                )),
            // Icon
            const ModernIconWidget(),
            // Name and Author
            Positioned(
              top: screenHeight * 0.62,
              left: screenWidth * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audioController.songs[audioController.index][0],
                    style: headline1,
                  ),
                  Text(audioController.songs[audioController.index][1], style: headline3),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Player
            Positioned(
              top: screenHeight * 0.74,
              child: SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: const PlayerWidget(),
              ),
            ),
          ],
        ));
  }
}
