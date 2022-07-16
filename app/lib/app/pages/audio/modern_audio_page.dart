import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bossa/app/controllers/audio_controller.dart';
import 'package:flutter/material.dart';

class ModernAudioPage extends StatefulWidget {
  final List songs;
  int index;

  ModernAudioPage({Key? key, required this.songs, required this.index})
      : super(key: key);

  @override
  State<ModernAudioPage> createState() => _ModernAudioPageState();
}

class _ModernAudioPageState extends State<ModernAudioPage> {
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
    Color primaryColor = Theme.of(context).primaryColor;

    TextStyle headline1 = Theme.of(context).textTheme.headline1!;
    TextStyle headline3 = Theme.of(context).textTheme.headline3!;

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
                      // Navigator.pushReplacementNamed(context, '/');
                      Navigator.of(context).pop();
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                )),
            // Icon
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
                    File(widget.songs[widget.index]['icon']),
                  ),
                  fit: BoxFit.cover,
                )),
              ),
            ),
            // Name and Author
            Positioned(
              top: screenHeight * 0.62,
              left: screenWidth * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.songs[widget.index]['title'],
                    style: headline1,
                  ),
                  Text(widget.songs[widget.index]['author'], style: headline3),
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
                child: audioController,
              ),
            ),
          ],
        ));
  }
}
