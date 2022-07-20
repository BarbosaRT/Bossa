import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color buttonColor = themeController.themeData.buttonTheme.colorScheme!.primary;
    
    return IconButton(
      padding: const EdgeInsets.only(bottom: 40, right: 40),
      icon: audioController.isPlaying
          ? Icon(              
              Icons.pause_circle_filled,
              size: 70,
              color: buttonColor,
            )
          : Icon(              
              Icons.play_circle_fill,
              size: 70,
              color: buttonColor,
            ),
      onPressed: () {
        audioController.start();
      },
    );
  }
}

class RandomButton extends StatelessWidget {
  const RandomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color buttonColor = themeController.themeData.buttonTheme.colorScheme!.secondary;

    return IconButton(
      icon: Icon(
        (audioController.isRandom ? Icons.shuffle_on_sharp : Icons.shuffle),
        size: 30,
        color: buttonColor,
      ),
      onPressed: () {
        audioController.random();
      },
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color buttonColor = themeController.themeData.buttonTheme.colorScheme!.secondary;

    return IconButton(
        icon: Icon(
          (audioController.isRepeat ? Icons.repeat_one : Icons.repeat),
          size: 30,
          color: buttonColor,
        ),
        onPressed: () {
          audioController.repeat();
        });
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color buttonColor = themeController.themeData.buttonTheme.colorScheme!.secondary;

    return IconButton(
      icon: Icon(
        Icons.skip_previous,
        size: 40,
        color: buttonColor,
      ),
      onPressed: () {
        audioController.previous();
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioNotifier audioController = context.watch<AudioNotifier>();
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();

    Color buttonColor = themeController.themeData.buttonTheme.colorScheme!.secondary;

    return IconButton(
      icon: Icon(
        Icons.skip_next,
        size: 40,
        color: buttonColor,
      ),
      onPressed: () {
        audioController.next();
      },
    );
  }
}

class AudioSlider extends StatelessWidget {
  const AudioSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeNotifier themeController = context.watch<ThemeNotifier>();
    final AudioNotifier audioController = context.watch<AudioNotifier>();

    Color activeColor = themeController.themeData.buttonTheme.colorScheme!.primary;
    Color inactiveColor = themeController.themeData.buttonTheme.colorScheme!.onBackground;

    return Slider(
      value: audioController.position.inSeconds.toDouble(),
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      min: 0.0,
      max: audioController.duration.inSeconds.toDouble(),
      onChanged: (double value) {
        audioController.slider(value);
      },
    );
  }
}