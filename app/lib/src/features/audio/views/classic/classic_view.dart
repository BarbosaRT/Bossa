import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/audio/views/classic/classic_icon_widget.dart';
import 'package:bossa/src/features/audio/components/player_widget.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassicAudioPage extends StatelessWidget {
  const ClassicAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    
    TextStyle? headline1 = themeController.textTheme.headline1;
    TextStyle? headline2 = themeController.textTheme.headline2;

    Color backgroundColor = themeController.themeData.backgroundColor;
    Color widgetColor = themeController.themeData.cardColor;
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
              height: screenHeight / 2,
              child: Container(
                color: primaryColor,
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
            // Player
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.4,
              height: screenHeight * 0.5,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: widgetColor,
                  ),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      // Song Name
                      Text(
                        audioController.songs[audioController.index][0],
                        style: headline1,
                        textAlign: TextAlign.center,
                      ),
                      // Author
                      Text(
                        audioController.songs[audioController.index][1],
                        style: headline2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const PlayerWidget(),
                    ],
                  ))),            
          // Image
          const ClassicIconWidget()
          ],
        ));
  }
}
