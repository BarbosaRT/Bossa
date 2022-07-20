import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/audio/components/player_buttons.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    TextStyle? headline3 = themeController.textTheme.headline3;
    

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  audioController.position.toString().split('.')[0].replaceFirst('0:', ''),
                  style: headline3,
                ),
                Text(
                  // 00:00:12.00515445ms
                  audioController.duration.toString().split('.')[0].replaceFirst('0:', ''),
                  style: headline3,
                ),
              ],
            )),
        const AudioSlider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            RepeatButton(),
            PreviousButton(),
            StartButton(),
            NextButton(),
            RandomButton(),
          ],
        ),
      ],
    );
  }
}