import 'dart:io';
import 'package:asuka/asuka.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongAddPage extends StatefulWidget {
  final SongModel? songToBeEdited;
  const SongAddPage({super.key, this.songToBeEdited});

  @override
  State<SongAddPage> createState() => _SongAddPageState();
}

class _SongAddPageState extends State<SongAddPage> {
  static String defaultIcon = UIConsts.assetImage;
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  final titleTextController = TextEditingController();
  final authorTextController = TextEditingController();

  final scrollController = ScrollController();

  bool editing = false;
  bool saveOffline = false;

  final SongModel defaultSong = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: '',
      path: '',
      author: 'author');

  SongModel songToBeAdded = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: '',
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
    final accentColor = colorController.currentScheme.accentColor;
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    TextStyle titleStyle = TextStyles().headline.copyWith(color: contrastColor);

    TextStyle authorStyle =
        TextStyles().headline2.copyWith(color: contrastColor);

    ImageProvider iconImage =
        ImageParser.getImageProviderFromString(songToBeAdded.icon);

    final offlineWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: x / 2),
      child: Container(
        width: size.width,
        height: x * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: backgroundAccent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Disponivel offline',
              style: authorStyle,
            ),
            Switch(
              value: songToBeAdded.path.isNotEmpty,
              onChanged: (value) async {
                if (!value) {
                  final icon = File(songToBeAdded.icon);
                  final path = File(songToBeAdded.path);

                  if (await icon.exists()) {
                    songToBeAdded.icon = '';
                    await icon.delete();
                  }
                  if (await path.exists()) {
                    songToBeAdded.path = '';
                    await path.delete();
                  }

                  if (SongParser().isSongFromYoutube(songToBeAdded.url)) {
                    final yt = YoutubeExplode();
                    final video = await yt.videos.get(
                        SongParser().parseYoutubeSongUrl(songToBeAdded.url));
                    songToBeAdded.icon =
                        YoutubeParser().getYoutubeThumbnail(video.thumbnails);
                  } else {
                    songToBeAdded.icon = UIConsts.assetImage;
                  }
                  if (mounted) {
                    setState(() {});
                  }
                  return;
                }

                Asuka.showSnackBar(
                  SnackBar(
                    backgroundColor: backgroundAccent,
                    duration: const Duration(days: 1),
                    content: Text(
                      'Baixando a música, por favor aguarde',
                      style: authorStyle,
                    ),
                  ),
                );
                songToBeAdded = await SongParser().parseSongBeforeSave(
                  songToBeAdded,
                  saveOffline: true,
                );
                Asuka.hideCurrentSnackBar();
                Asuka.showSnackBar(
                  SnackBar(
                    backgroundColor: accentColor,
                    content: Text(
                      'Música baixada com sucesso',
                      style: authorStyle,
                    ),
                  ),
                );
                if (mounted) {
                  setState(() {});
                }
              },
            )
          ],
        ),
      ),
    );
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
                if (widget.songToBeEdited != songToBeAdded) {
                  Asuka.hideCurrentSnackBar();
                  Asuka.showSnackBar(
                    SnackBar(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      duration: const Duration(days: 1),
                      content: Container(
                        height: 100,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: backgroundAccent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(
                                  'Você têm mudanças não salvas, você deseja realmente sair?',
                                  style: authorStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Asuka.hideCurrentSnackBar();
                                          Modular.to.popAndPushNamed('/');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              'Sim',
                                              style: authorStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Asuka.hideCurrentSnackBar();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              'Não',
                                              style: authorStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  Modular.to.popAndPushNamed('/');
                }
              },
              child: FaIcon(
                FontAwesomeIcons.xmark,
                color: contrastColor,
                size: iconSize * 1.5,
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

                  Modular.to.popUntil(ModalRoute.withName('/'));
                },
                child: FaIcon(
                  editing
                      ? FontAwesomeIcons.solidPenToSquare
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
                  padding: EdgeInsets.symmetric(horizontal: x / 2),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: size.width,
                          height: size.width + x * 3,
                          child: Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: size.width - x * 2,
                                  height: size.width - x * 2,
                                  child: GestureDetector(
                                    onTap: saveIcon,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: iconImage,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: x * 2.5,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: x / 2),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: size.width,
                                        height: x * 1.5,
                                        child: TextField(
                                          controller: titleTextController,
                                          decoration: InputDecoration(
                                            hintText: 'Titulo',
                                            hintStyle: titleStyle,
                                            border: InputBorder.none,
                                            isDense: true,
                                            helperMaxLines: 1,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: titleStyle,
                                          textAlignVertical:
                                              TextAlignVertical.center,
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
                                      SizedBox(
                                        width: size.width,
                                        height: x,
                                        child: TextField(
                                          controller: authorTextController,
                                          decoration: InputDecoration(
                                              hintText: 'Autor',
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
                                ),
                              ),
                              songToBeAdded.url.isNotEmpty
                                  ? offlineWidget
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: iconSize * 0.5,
                        right: x / 2,
                        child: SizedBox(
                          width: iconSize,
                          height: 50,
                          child: GestureDetector(
                            onTap: saveSong,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.music,
                                  color: contrastColor,
                                  size: iconSize,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                songToBeAdded.path.isEmpty &&
                                        songToBeAdded.url.isEmpty
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
