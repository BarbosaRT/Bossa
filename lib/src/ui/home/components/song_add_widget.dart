import 'dart:io';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SongAddWidget extends StatefulWidget {
  final void Function() callback;
  const SongAddWidget({super.key, required this.callback});

  @override
  State<SongAddWidget> createState() => _SongAddWidgetState();
}

class _SongAddWidgetState extends State<SongAddWidget> {
  static String defaultIcon = 'assets/images/disc.png';
  static double x = 30.0;
  final titleTextController = TextEditingController();
  final authorTextController = TextEditingController();

  final scrollController = ScrollController();

  final SongModel defaultSong = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: 'url',
      path: '',
      author: 'author');

  SongModel songToBeAdded = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: 'url',
      path: '',
      author: 'author');

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

  void saveSong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mp3', 'flac', 'wav', 'm4a']);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        songToBeAdded.path = file.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final songDataManager = Modular.get<SongDataManager>();
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentScheme.accentColor;
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final backgroundColor = colorController.currentScheme.backgroundColor;

    ButtonStyle saveButtonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(accentColor),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );

    ButtonStyle songButtonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );

    TextStyle titleStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 40);

    TextStyle authorStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 20);

    ImageProvider iconImage = AssetImage(songToBeAdded.icon);
    if (songToBeAdded.icon != defaultIcon) {
      iconImage = FileImage(File(songToBeAdded.icon));
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: size.width,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: backgroundColor,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: x / 2, horizontal: x / 2),
                  child: Container(
                    width: size.width - x,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: backgroundAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: GestureDetector(
                          onTap: saveIcon,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: iconImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: size.width - 175,
                            height: x * 2,
                            child: TextField(
                              controller: titleTextController,
                              decoration: InputDecoration(
                                  hintText: 'Title',
                                  hintStyle: titleStyle,
                                  border: InputBorder.none),
                              style: titleStyle,
                              onChanged: (value) {
                                setState(() {
                                  songToBeAdded.title = value;
                                });
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  songToBeAdded.title = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: size.width - 175,
                            height: x,
                            child: TextField(
                              controller: authorTextController,
                              decoration: InputDecoration(
                                  hintText: 'Author',
                                  hintStyle: authorStyle,
                                  border: InputBorder.none),
                              style: authorStyle,
                              onChanged: (value) {
                                setState(() {
                                  songToBeAdded.author = value;
                                });
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  songToBeAdded.author = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        style: saveButtonStyle,
                        onPressed: () async {
                          songToBeAdded = await SongParser()
                              .parseSongBeforeSave(songToBeAdded);
                          songDataManager.addSong(songToBeAdded);
                          setState(() {
                            songToBeAdded =
                                SongModel.fromMap(defaultSong.toMap());
                            titleTextController.text = '';
                            authorTextController.text = '';
                          });
                          widget.callback();
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.solidFloppyDisk,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: x / 2,
                    ),
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: ElevatedButton(
                        style: songButtonStyle,
                        onPressed: saveSong,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.music,
                              color: accentColor,
                              size: 30,
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                            songToBeAdded.path.isEmpty
                                ? Container()
                                : Container(
                                    width: 30,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: accentColor,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
