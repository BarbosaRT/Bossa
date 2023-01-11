import 'dart:io';

import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SongAddPage extends StatefulWidget {
  const SongAddPage({super.key});

  @override
  State<SongAddPage> createState() => _SongAddPageState();
}

class _SongAddPageState extends State<SongAddPage> {
  static String defaultIcon = 'assets/images/disk_icon.png';
  SongModel songToBeAdded =
      SongModel(id: 0, title: 'title', icon: defaultIcon, url: 'url', path: '');

  void saveIcon() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        songToBeAdded.icon = file.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;
    // final accentColor = colorController.currentScheme.accentColor;
    // final contrastColor = colorController.currentScheme.contrastColor;

    ImageProvider iconImage = AssetImage(songToBeAdded.icon);
    if (songToBeAdded.icon != defaultIcon) {
      FileImage(File(songToBeAdded.icon));
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SizedBox(
            width: 350,
            height: 350,
            child: GestureDetector(
              onTap: saveIcon,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: iconImage,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
