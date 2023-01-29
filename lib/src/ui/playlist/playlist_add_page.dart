import 'dart:ui';
import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlaylistSongContainer extends StatefulWidget {
  final SongModel song;
  final void Function() removeSong;
  final void Function()? addSong;
  const PlaylistSongContainer(
      {super.key, required this.song, required this.removeSong, this.addSong});

  @override
  State<PlaylistSongContainer> createState() => _PlaylistSongContainerState();
}

class _PlaylistSongContainerState extends State<PlaylistSongContainer> {
  bool isAdding = false;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    if (widget.addSong != null) {
      isAdding = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final contrastColor = colorController.currentTheme.contrastColor;
    final contrastAccent = colorController.currentTheme.contrastAccent;

    TextStyle titleStyle = TextStyles().headline2.copyWith(
          color: contrastColor,
        );
    TextStyle authorStyle = TextStyles().headline3.copyWith(
          color: contrastAccent,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        width: size.width,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image(
                    image: ImageParser.getImageProviderFromString(
                      widget.song.icon,
                    ),
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width - 150,
                        height: 20,
                        child: TextStyles().getConstrainedTextByWidth(
                          textStyle: titleStyle,
                          text: widget.song.title,
                          textWidth: size.width,
                        ),
                      ),
                      Text(
                        widget.song.author,
                        style: authorStyle,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  isAdding ? widget.addSong?.call() : widget.removeSong();
                },
                child: FaIcon(
                    isAdding
                        ? FontAwesomeIcons.circlePlus
                        : FontAwesomeIcons.circleMinus,
                    color: contrastColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistAddPage extends StatefulWidget {
  final PlaylistModel? playlistToBeEdited;
  const PlaylistAddPage({super.key, this.playlistToBeEdited});

  @override
  State<PlaylistAddPage> createState() => _PlaylistAddPageState();
}

class _PlaylistAddPageState extends State<PlaylistAddPage> {
  static String defaultIcon = UIConsts.assetImage;
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  final titleTextController = TextEditingController();

  final scrollController = ScrollController();

  bool editing = false;

  final PlaylistModel defaultPlaylist = PlaylistModel(
    id: 0,
    title: 'title',
    icon: defaultIcon,
    songs: [],
  );

  PlaylistModel playlistToBeAdded = PlaylistModel(
    id: 0,
    title: 'title',
    icon: defaultIcon,
    songs: [],
  );
  List<SongModel> songs = [];
  SongModel? selectedSong;

  @override
  void initState() {
    super.initState();
    loadSongs();
    if (widget.playlistToBeEdited != null) {
      playlistToBeAdded =
          PlaylistModel.fromMap(widget.playlistToBeEdited!.toMap());
      editing = true;
      titleTextController.text = playlistToBeAdded.title;
    }
  }

  void saveIcon() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        playlistToBeAdded.icon = file.path!;
      });
    }
  }

  void loadSongs() async {
    final songDataManager = Modular.get<SongDataManager>();
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playlistDataManager = Modular.get<PlaylistDataManager>();

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final accentColor = colorController.currentTheme.accentColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    TextStyle titleStyle = TextStyles().headline.copyWith(color: contrastColor);

    TextStyle snackbarStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    ImageProvider iconImage =
        ImageParser.getImageProviderFromString(playlistToBeAdded.icon);

    List<int> ids = [];

    List<PlaylistSongContainer> songsInPlaylist = [];
    for (SongModel song in playlistToBeAdded.songs) {
      ids.add(song.id);

      songsInPlaylist.add(
        PlaylistSongContainer(
          key: ValueKey(song),
          song: song,
          removeSong: () {
            setState(() {
              playlistToBeAdded.songs.remove(song);
            });
          },
        ),
      );
    }

    List<PlaylistSongContainer> songsToAdd = [];
    for (SongModel song in songs) {
      if (ids.contains(song.id)) {
        continue;
      }
      songsToAdd.add(
        PlaylistSongContainer(
          song: song,
          removeSong: () {},
          addSong: () {
            setState(() {
              playlistToBeAdded.songs.add(song);
            });
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              if (widget.playlistToBeEdited != playlistToBeAdded) {
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
                                style: snackbarStyle,
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
                                            style: snackbarStyle,
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
                                            style: snackbarStyle,
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
              size: iconSize,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (playlistToBeAdded.songs.isEmpty) {
                    return;
                  }
                  editing
                      ? playlistDataManager.editPlaylist(playlistToBeAdded)
                      : playlistDataManager.addPlaylist(playlistToBeAdded);

                  Modular.to.popUntil(ModalRoute.withName('/'));
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
                height: size.height,
                width: size.width,
                color: backgroundColor,
                child: Padding(
                  padding: EdgeInsets.only(left: x / 2, right: x / 2),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: saveIcon,
                              child: Image(
                                image: iconImage,
                                fit: BoxFit.cover,
                                alignment: FractionalOffset.center,
                                width: 280 - x * 2,
                                height: 280 - x * 2,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: size.width,
                            height: x,
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
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: (value) {
                                setState(() {
                                  playlistToBeAdded.title = value;
                                });
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  playlistToBeAdded.title = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: size.height / 3,
                                width: size.width,
                                child: Stack(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ReorderableListView(
                                        proxyDecorator: (Widget child,
                                            int index,
                                            Animation<double> animation) {
                                          return AnimatedBuilder(
                                            animation: animation,
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              final double animValue = Curves
                                                  .easeInOut
                                                  .transform(animation.value);
                                              final double elevation =
                                                  lerpDouble(0, 6, animValue)!;
                                              final double scale = lerpDouble(
                                                  1, 1.1, animValue)!;
                                              return Transform.scale(
                                                scale: scale,
                                                child: Material(
                                                  elevation: elevation,
                                                  color: Colors.transparent,
                                                  shadowColor: Colors.black,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: child,
                                          );
                                        },
                                        onReorder: (oldIndex, newIndex) {
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }
                                          SongModel song = SongModel.fromMap(
                                              playlistToBeAdded.songs[oldIndex]
                                                  .toMap());
                                          playlistToBeAdded.songs
                                              .removeAt(oldIndex);
                                          setState(() {
                                            playlistToBeAdded.songs
                                                .insert(newIndex, song);
                                          });
                                        },
                                        children: songsInPlaylist,
                                      ),
                                    ),
                                    //
                                    // Gradient
                                    //
                                    Positioned(
                                      bottom: 0,
                                      child: MouseRegion(
                                        opaque: false,
                                        child: Container(
                                          height: 50,
                                          width: size.width,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                backgroundColor.withOpacity(0),
                                                backgroundColor,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  width: size.width,
                                  child: Text(
                                    'Músicas para adicionar',
                                    style: titleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height / 3,
                                width: size.width,
                                child: ListView(
                                  children: songsToAdd,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
