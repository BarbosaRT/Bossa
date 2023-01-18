import 'dart:io';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaylistSongContainer extends StatefulWidget {
  final SongModel song;
  final void Function() removeSong;
  const PlaylistSongContainer(
      {super.key, required this.song, required this.removeSong});

  @override
  State<PlaylistSongContainer> createState() => _PlaylistSongContainerState();
}

class _PlaylistSongContainerState extends State<PlaylistSongContainer> {
  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final contrastColor = colorController.currentScheme.contrastColor;

    TextStyle textStyle = GoogleFonts.poppins(
      color: contrastColor,
      fontSize: 13,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.song.title,
              style: textStyle,
            ),
            ElevatedButton(
              onPressed: () {
                widget.removeSong();
              },
              child: const Icon(
                Icons.delete,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlaylistAddPage extends StatefulWidget {
  final PlaylistModel? playlistToBeEdited;
  final void Function() callback;
  const PlaylistAddPage(
      {super.key, required this.callback, this.playlistToBeEdited});

  @override
  State<PlaylistAddPage> createState() => _PlaylistAddPageState();
}

class _PlaylistAddPageState extends State<PlaylistAddPage> {
  static String defaultIcon = 'assets/images/disc.png';
  static double x = 30.0;
  final titleTextController = TextEditingController();

  final scrollController = ScrollController();

  bool editing = false;
  bool cropImages = true;

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

    TextStyle titleStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 24);

    TextStyle dropdownStyle =
        GoogleFonts.poppins(color: contrastColor, fontSize: 14);

    ImageProvider iconImage =
        ImageParser.getImageProviderFromString(playlistToBeAdded.icon);

    List<DropdownMenuItem<SongModel>> dropdownList = [];
    for (SongModel song in songs) {
      String title = song.title;
      if (title.length > 35) {
        title = '${title.substring(0, 35)}...';
      }

      dropdownList.add(
        DropdownMenuItem<SongModel>(
          value: song,
          child: Text(
            title,
            style: dropdownStyle,
          ),
        ),
      );
    }

    List<PlaylistSongContainer> songsInPlaylist = [];
    for (SongModel song in playlistToBeAdded.songs) {
      String title = song.title;
      if (title.length > 35) {
        title = '${title.substring(0, 35)}...';
      }
      song.title = title;

      songsInPlaylist.add(
        PlaylistSongContainer(
          song: song,
          removeSong: () {
            setState(() {
              playlistToBeAdded.songs.remove(song);
            });
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              Modular.to.pop();
            },
            child: FaIcon(
              FontAwesomeIcons.xmark,
              color: contrastColor,
              size: 40,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (selectedSong == null) {
                    return;
                  }
                  setState(
                    () {
                      playlistToBeAdded.songs.add(selectedSong!);
                    },
                  );
                },
                child: FaIcon(
                  FontAwesomeIcons.solidFloppyDisk,
                  color: contrastColor,
                  size: 40,
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
              SizedBox(
                height: x * 2,
              ),
              Container(
                height: size.height - x * 2,
                width: size.width,
                color: backgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: x / 2, right: x / 2),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: size.width,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: saveIcon,
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.center,
                                          heightFactor: cropImages ? 0.75 : 1,
                                          widthFactor: cropImages ? 0.75 : 1,
                                          child: Image(
                                            image: iconImage,
                                            fit: BoxFit.cover,
                                            alignment: FractionalOffset.center,
                                            width: size.width - x,
                                            height: size.width - x,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          DropdownButton<SongModel>(
                                            value: selectedSong,
                                            style: dropdownStyle,
                                            dropdownColor: backgroundAccent,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedSong = value;
                                              });
                                            },
                                            items: dropdownList,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (selectedSong == null) {
                                                return;
                                              }
                                              setState(
                                                () {
                                                  playlistToBeAdded.songs
                                                      .add(selectedSong!);
                                                },
                                              );
                                            },
                                            child: const Icon(Icons.add),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 160,
                                        width: size.width - 185,
                                        child: ListView(
                                          children: songsInPlaylist,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 50,
                              width: size.width - 185,
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
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
