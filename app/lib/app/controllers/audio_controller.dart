import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bossa/app/components/audio_components.dart';
import 'package:flutter/material.dart';

class AudioController extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  final List songs;
  int index;
  bool isRepeat = false;
  var audioPage;

  AudioController({
    Key? key,
    required this.advancedPlayer,
    required this.songs,
    required this.index,
    required this.audioPage,
  }) : super(key: key);

  @override
  State<AudioController> createState() => _AudioControllerState();
}

class _AudioControllerState extends State<AudioController> {
  Duration _duration = const Duration();
  Duration _position = const Duration();
  // final String path = 'https://us4.internet-radio.com/proxy/wsjf?mp=/strea';
  final String localFile = 'audio/boate.mp3';
  bool isPlaying = false;
  bool isRandom = false;
  String songPath = '';
  final AudioWidgets _audioWidgets = AudioWidgets();
  List indexes = [];
  Random random = Random(69);

  final List<IconData> _icons = [
    Icons.play_circle_fill,
    Icons.pause_circle_filled,
  ];

  @override
  void initState() {
    super.initState();
    // Initializes the indexes creating an array from 0 to the songs length
    for (int i = 0; i < widget.songs.length; i++) {
      indexes.add(i);
    }
    widget.advancedPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    widget.advancedPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    widget.advancedPlayer.onPlayerComplete.listen((event) {
      if ((_duration.inSeconds >= _position.inSeconds) &&
          _position.inSeconds > 0) {
        if (!widget.isRepeat) {
          if (isRandom) {
            if (indexes.length > 1) {
              indexes.remove(widget.index);
              int number = random.nextInt(indexes.length);
              widget.index = indexes[number];
            }
          } else {
            widget.index = (widget.index > widget.songs.length - 1)
                ? widget.songs.length - 1
                : widget.index + 1;
          }
          songPath = widget.songs[widget.index]['audio'];
          widget.advancedPlayer.setSourceDeviceFile(songPath);
          _position = const Duration();
          isPlaying = false;
          widget.audioPage.update(widget.index);
          start();
        }
      }
    });

    // Funcionou
    // widget.advancedPlayer.setSourceUrl(path);

    songPath = widget.songs[widget.index]['audio'];
    widget.advancedPlayer.setSourceDeviceFile(songPath);
    widget.advancedPlayer.setVolume(1.0);
    widget.advancedPlayer.setPlaybackRate(1.0);
  }

  void start() {
    if (isPlaying) {
      widget.advancedPlayer.pause();
    } else {
      widget.advancedPlayer.play(DeviceFileSource(songPath));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  Widget btnSlow(Color color) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous,
        size: 40,
        color: color,
      ),
      onPressed: () {
        widget.advancedPlayer.setPlaybackRate(0.5);
      },
    );
  }

  Widget btnFast(Color color) {
    return IconButton(
      icon: Icon(
        Icons.skip_next,
        size: 40,
        color: color,
      ),
      onPressed: () {
        widget.advancedPlayer.setPlaybackRate(1.5);
      },
    );
  }

  void onPressRandom() {
    setState(() {
      isRandom = !isRandom;
    });
    widget.advancedPlayer.setPlaybackRate(1);
  }

  void onPressRepeat() {
    setState(() {
      widget.isRepeat = !widget.isRepeat;
      widget.advancedPlayer.setReleaseMode(
          (widget.isRepeat ? ReleaseMode.loop : ReleaseMode.release));
    });
  }

  Widget slider(Color activeColor, Color inactiveColor) {
    return Slider(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      value: _position.inSeconds.toDouble(),
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      onChanged: (double value) {
        if (!isPlaying) {
          start();
        }
        setState(() {
          changeToSecond(value.toInt());
          value = value;
        });
      },
    );
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    widget.advancedPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor1 = Theme.of(context).buttonTheme.colorScheme!.primary;
    Color buttonColor2 = Theme.of(context).buttonTheme.colorScheme!.secondary;
    Color sliderColor1 = Theme.of(context).buttonTheme.colorScheme!.primary;
    Color sliderColor2 =
        Theme.of(context).buttonTheme.colorScheme!.onBackground;

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _position.toString().split('.')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  // 00:00:12.00515445ms
                  _duration.toString().split('.')[0],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )),
        slider(sliderColor1, sliderColor2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //
            // Repeat Button
            //
            _audioWidgets.btnRepeat(
                widget.isRepeat, onPressRepeat, buttonColor2),
            //
            // Slow Button
            //
            SizedBox(height: 60, child: btnSlow(buttonColor2)),
            //
            // Play/Pause Button
            //
            _audioWidgets.btnStart(
                isPlaying, start, _icons[1], _icons[0], buttonColor1),
            //
            // Fast Button
            //
            SizedBox(height: 60, child: btnFast(buttonColor2)),
            //
            // Random Button
            //
            _audioWidgets.btnRandom(isRandom, onPressRandom, buttonColor2),
          ],
        ),
      ],
    );
  }
}
