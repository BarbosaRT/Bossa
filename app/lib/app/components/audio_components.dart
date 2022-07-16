import 'package:flutter/material.dart';

class AudioWidgets {
  Widget btnStart(bool playing, Function onPress, IconData playIcon,
      IconData pauseIcon, Color color) {
    return IconButton(
      padding: const EdgeInsets.only(bottom: 40, right: 40),
      icon: playing
          ? Icon(
              playIcon,
              size: 70,
              color: color,
            )
          : Icon(
              pauseIcon,
              size: 70,
              color: color,
            ),
      onPressed: () {
        onPress();
      },
    );
  }

  Widget btnRandom(bool random, Function onPress, Color color) {
    return IconButton(
      icon: Icon(
        (random ? Icons.shuffle_on_sharp : Icons.shuffle),
        size: 30,
        color: color,
      ),
      onPressed: () {
        onPress();
      },
    );
  }

  Widget btnRepeat(bool repeat, Function onPress, Color color) {
    return IconButton(
        icon: Icon(
          (repeat ? Icons.repeat_one : Icons.repeat),
          size: 30,
          color: color,
        ),
        onPressed: () {
          onPress();
        });
  }
}
