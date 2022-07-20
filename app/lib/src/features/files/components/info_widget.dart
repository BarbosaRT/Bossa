import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/files/components/author_widget.dart';
import 'package:bossa/src/features/files/components/icon_widget.dart';
import 'package:bossa/src/features/files/components/title_widget.dart';
import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});


  @override
  Widget build(BuildContext context) {

    final fileController = context.watch<FileNotifier>();
    final themeController = context.watch<ThemeNotifier>(); 
    final audioController = context.watch<AudioNotifier>();  

    Color backgroundColor = themeController.themeData.backgroundColor; 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            IconWidget(),
            TitleWidget(),
            AuthorWidget(),
          ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: fileController.songModel.isFilled()
            ? Colors.blue 
            : Colors.grey.shade400,
        onPressed:
            fileController.songModel.isFilled() ? () {
              fileController.save();
              audioController.load();
              Navigator.pushReplacementNamed(context, '/');
            }: null,
        child: const Icon(Icons.add),
      ),
    );
  }
}