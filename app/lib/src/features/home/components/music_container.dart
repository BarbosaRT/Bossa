import 'dart:io';

import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicContainer extends StatelessWidget {
  const MusicContainer({super.key});

  @override
  Widget build(BuildContext context) {   
    final audioController = context.watch<AudioNotifier>();
    final themeController = context.watch<ThemeNotifier>();

    // Esta sendo rebuildado toda hora

    Color widgetColor = themeController.themeData.cardColor;
    TextStyle? headline3 = themeController.textTheme.headline3;
    TextStyle? headline4 = themeController.textTheme.headline4;  


    return audioController.songs.isNotEmpty ? 
    ListView.builder(
      itemCount: audioController.songs.length,
      itemBuilder: (_, i) {
        return audioController.songs[i].length > 3 
        ? GestureDetector(
          onTap: () {
            audioController.changeIndex(i);
            Navigator.popAndPushNamed(context, '/player');
          },
          child: Container(
            margin: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(10),
                    color: widgetColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                        color: Colors.grey
                            .withOpacity(0.2),
                      )
                    ]),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 90,
                          height: 120,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),
                              image: DecorationImage(
                                image: FileImage(
                                  File(audioController.songs[i][2]),
                                ),
                                fit: BoxFit.cover,
                              )),
                        ),
                        const SizedBox(width: 10),
                        // Infos
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              audioController.songs[i][0],
                              style: headline3,
                            ),
                            // Author
                            Text(
                                audioController.songs[i][1],
                                style: headline4),
                          ],
                        )
                      ],
                    ))),
          ),
        )
        : Container();
      })
      : Container();
  }
}