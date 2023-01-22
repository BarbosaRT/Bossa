import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SongAddPage extends StatefulWidget {
  final SongModel? songToBeEdited;
  const SongAddPage({super.key, this.songToBeEdited});

  @override
  State<SongAddPage> createState() => _SongAddPageState();
}

class _SongAddPageState extends State<SongAddPage> {
  static String defaultIcon = 'assets/images/disc.png';
  static double x = 30.0;
  double iconSize = UIConsts.iconSize.toDouble();
  final titleTextController = TextEditingController();
  final authorTextController = TextEditingController();

  final scrollController = ScrollController();

  bool editing = false;

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

  @override
  void initState() {
    super.initState();
    if (widget.songToBeEdited != null) {
      songToBeAdded = SongModel.fromMap(widget.songToBeEdited!.toMap());
      editing = true;
      titleTextController.text = songToBeAdded.title;
      authorTextController.text = songToBeAdded.author;
    }
  }

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
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;

    TextStyle titleStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 40);

    TextStyle authorStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 20);

    ImageProvider iconImage =
        ImageParser.getImageProviderFromString(songToBeAdded.icon);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: Padding(
          padding: EdgeInsets.only(left: x),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Modular.to.pop();
              },
              child: FaIcon(
                FontAwesomeIcons.xmark,
                color: contrastColor,
                size: iconSize,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: x),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  songToBeAdded =
                      await SongParser().parseSongBeforeSave(songToBeAdded);
                  editing
                      ? songDataManager.editSong(songToBeAdded)
                      : songDataManager.addSong(songToBeAdded);
                  Modular.to.pop();
                },
                child: FaIcon(
                  editing
                      ? FontAwesomeIcons.penToSquare
                      : FontAwesomeIcons.solidFloppyDisk,
                  color: contrastColor,
                  size: editing ? iconSize : iconSize * 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: ListView(
            children: [
              Container(
                width: size.width,
                height: size.height - x * 2 - 40,
                color: backgroundColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: x),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Center(
                            child: SizedBox(
                              width: size.width - x * 2,
                              height: size.width - x * 2,
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
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width,
                                  height: 50,
                                  child: TextField(
                                    controller: titleTextController,
                                    decoration: InputDecoration(
                                      hintText: 'Title',
                                      hintStyle: titleStyle,
                                      border: InputBorder.none,
                                      isDense: true,
                                      helperMaxLines: 1,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: titleStyle,
                                    textAlignVertical: TextAlignVertical.center,
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
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: size.width,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 50,
                                  child: GestureDetector(
                                    onTap: saveSong,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.music,
                                          color: contrastColor,
                                          size: iconSize,
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
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: contrastColor,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
