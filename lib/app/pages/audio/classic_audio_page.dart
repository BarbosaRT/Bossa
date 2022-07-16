import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:bossa/app/controllers/audio_controller.dart';

class ClassicAudioPage extends StatefulWidget {
  final List songs;
  int index;

  ClassicAudioPage({Key? key, required this.songs, required this.index})
      : super(key: key);

  @override
  State<ClassicAudioPage> createState() => _ClassicAudioPageState();
}

class _ClassicAudioPageState extends State<ClassicAudioPage> {
  static late AudioPlayer advancedPlayer;
  late AudioController audioController;

  @override
  void initState() {
    super.initState();
    advancedPlayer = AudioPlayer();
    audioController = AudioController(
      advancedPlayer: advancedPlayer,
      songs: widget.songs,
      index: widget.index,
      audioPage: this,
    );
    advancedPlayer.onPlayerComplete.listen((event) {
      if (!audioController.isRepeat && widget.index < widget.songs.length - 1) {
        setState(() {
          widget.index += 1;
        });
      }
    });
  }

  void update(int index) {
    setState(() {
      widget.index = index;
    });
  }

  @override
  void dispose() {
    advancedPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    Color backgroundColor = Theme.of(context).backgroundColor;
    Color widgetColor = Theme.of(context).cardColor;
    Color widgetColor2 = Theme.of(context).canvasColor;
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(children: [
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
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // Navigator.pushReplacementNamed(context, '/');
                    Navigator.of(context).pop();
                  },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              )),
          // Player
          Positioned(
              left: 0,
              right: 0,
              top: screenHeight * 0.4,
              height: screenHeight * 0.4,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: widgetColor,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                      // Song Name
                      Text(
                        widget.songs[widget.index]['title'],
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir'),
                      ),
                      // Author
                      Text(widget.songs[widget.index]['author'],
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                      audioController,
                    ],
                  ))),
          // Image
          Positioned(
              top: screenHeight * 0.15,
              // 150 -> Size of the icon
              left: (screenWidth - screenWidth * 0.7) / 2,
              right: (screenWidth - screenWidth * 0.7) / 2,
              height: screenHeight / 3,
              child: Container(
                decoration: BoxDecoration(
                    color: widgetColor2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widgetColor2,
                      width: 2,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widgetColor2,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File(widget.songs[widget.index]['icon']),
                          ),
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              )),
        ]));
  }
}
