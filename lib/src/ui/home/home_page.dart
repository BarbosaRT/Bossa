import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/ui/home/components/playlist_add_widget.dart';
import 'package:bossa/src/ui/home/components/song_add_widget.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

enum Pages { home, search, list, config }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double x = 30.0;

  List<SongModel> songs = [];
  List<PlaylistModel> playlists = [];

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void loadSongs() async {
    final songDataManager = Modular.get<SongDataManager>();
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  void loadPlaylists() async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    playlists = await playlistDataManager.loadPlaylists();
    setState(() {});
  }

  Widget addWidget({
    required void Function(String url) urlAdd,
    required String addText,
    required String fromYoutubeText,
    required String fromFileText,
    required Widget addWidget,
  }) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final popupStyle = GoogleFonts.poppins(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal);

    return ElevatedButton(
      onPressed: () {
        Asuka.showModalBottomSheet(
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          builder: (context) {
            return SizedBox(
              width: size.width,
              height: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: x),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Asuka.showModalBottomSheet(
                          isDismissible: false,
                          backgroundColor: backgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          builder: (context) {
                            String url = '';
                            final urlTextController = TextEditingController();

                            return SizedBox(
                              width: size.width,
                              height: 100,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: x),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: x / 3,
                                    ),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            color: backgroundColor,
                                          ),
                                          child: Container(
                                            width: size.width - x,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: backgroundAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: x / 2,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: urlTextController,
                                            decoration: InputDecoration(
                                                hintText: 'Url',
                                                hintStyle: popupStyle),
                                            style: popupStyle,
                                            onChanged: (value) {
                                              url = value.toString();
                                            },
                                            onSubmitted: (value) {
                                              url = value.toString();
                                            },
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            urlAdd(url);
                                          },
                                          child: const FaIcon(
                                            FontAwesomeIcons.plus,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        fromYoutubeText,
                        style: popupStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Asuka.showModalBottomSheet(
                          isDismissible: false,
                          backgroundColor: backgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          builder: (context) {
                            return addWidget;
                          },
                        );
                      },
                      child: Text(
                        fromFileText,
                        style: popupStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Text(
        addText,
        style: popupStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final textStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 28, fontWeight: FontWeight.normal);

    final headerStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 28, fontWeight: FontWeight.bold);

    final popupStyle = GoogleFonts.poppins(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal);

    final buttonStyle = ButtonStyle(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    List<Widget> songContainers = [];
    for (SongModel song in songs) {
      songContainers.add(
        GestureDetector(
          onLongPress: () {
            Asuka.showModalBottomSheet(
              backgroundColor: backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              builder: (context) {
                return Row(
                  children: [
                    SizedBox(
                      width: x / 2,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        songDataManager.removeSong(song);
                        loadSongs();
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.trash,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      width: x / 2,
                    ),
                  ],
                );
              },
            );
          },
          child: Image(
            image: ImageParser.getImageProviderFromString(
              song.icon,
            ),
            width: 100,
            height: 100,
          ),
        ),
      );
    }

    List<Widget> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        GestureDetector(
          onLongPress: () {
            Asuka.showModalBottomSheet(
              backgroundColor: backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              builder: (context) {
                return Row(
                  children: [
                    SizedBox(
                      width: x / 2,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        playlistDataManager.deletePlaylist(playlist);
                        loadPlaylists();
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.trash,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      width: x / 2,
                    ),
                  ],
                );
              },
            );
          },
          child: Image(
            image: ImageParser.getImageProviderFromString(
              playlist.icon,
            ),
            width: 100,
            height: 100,
          ),
        ),
      );
    }

    final addSongWidget = addWidget(
        addWidget: SizedBox(
          width: size.width,
          height: 240,
          child: SongAddWidget(
            callback: loadSongs,
          ),
        ),
        urlAdd: (url) async {
          final youtubeParser = YoutubeParser(songDataManager: songDataManager);
          SongModel song = await youtubeParser.convertYoutubeSong(url);
          songDataManager.addSong(song);
        },
        fromYoutubeText: 'Song From Youtube',
        fromFileText: 'Song from File',
        addText: 'Add Song');

    final addPlaylistWidget = addWidget(
        addWidget: SizedBox(
          width: size.width,
          height: 320,
          child: PlaylistAddWidget(
            callback: loadPlaylists,
          ),
        ),
        urlAdd: (url) async {
          final youtubeParser = YoutubeParser(songDataManager: songDataManager);
          SongModel song = await youtubeParser.convertYoutubeSong(url);
          songDataManager.addSong(song);
        },
        fromYoutubeText: 'Playlist From Youtube',
        fromFileText: 'Create a New Playlist',
        addText: 'Add Playlist');

    final adPlaylistWidget = ElevatedButton(
      onPressed: () {
        Asuka.showModalBottomSheet(
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          builder: (context) {
            return SizedBox(
              width: size.width,
              height: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: x),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Asuka.showModalBottomSheet(
                          isDismissible: false,
                          backgroundColor: backgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          builder: (context) {
                            String url = '';
                            final urlTextController = TextEditingController();

                            return SizedBox(
                              width: size.width,
                              height: 120,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: x),
                                child: Column(
                                  children: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: size.width - x,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: backgroundAccent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    TextField(
                                      controller: urlTextController,
                                      decoration: InputDecoration(
                                          hintText: 'Url',
                                          hintStyle: popupStyle,
                                          border: InputBorder.none),
                                      style: popupStyle,
                                      onChanged: (value) {
                                        url = value.toString();
                                      },
                                      onSubmitted: (value) {
                                        url = value.toString();
                                      },
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final youtubeParser = YoutubeParser(
                                            songDataManager: songDataManager);
                                        SongModel song = await youtubeParser
                                            .convertYoutubeSong(url);
                                        songDataManager.addSong(song);
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.plus,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Playlist from Youtube',
                        style: popupStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Asuka.showModalBottomSheet(
                          backgroundColor: backgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          builder: (context) {
                            return SizedBox(
                              width: size.width,
                              height: 300,
                              child: PlaylistAddWidget(
                                callback: loadPlaylists,
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Create a New Playlist',
                        style: popupStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Text(
        'Add Playlist',
        style: popupStyle,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: x / 2,
                  ),
                  Text('Bem-vindo', style: headerStyle),
                ],
              ),
              //
              // Plus Button
              //
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      Asuka.showModalBottomSheet(
                        backgroundColor: backgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        builder: (context) {
                          return SizedBox(
                            width: size.width,
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: x),
                              child: Column(
                                children: [
                                  addSongWidget,
                                  addPlaylistWidget,
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: contrastColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
              //
              // Home List
              //
              Positioned(
                top: 50,
                left: x / 2,
                child: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 160,
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recem Adicionados', style: textStyle),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: songContainers,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mais Ouvidos', style: textStyle),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: songContainers,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Populares', style: textStyle),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: songContainers,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Playlists', style: textStyle),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: playlistContainers,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
              //
              // Bottom Part
              //
              Positioned(
                bottom: 0,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backgroundColor.withAlpha(0),
                        backgroundColor,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: x,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: x / 2,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: buttonStyle.copyWith(
                                      alignment: Alignment.centerLeft,
                                    ),
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.house,
                                      color: contrastColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.magnifyingGlass,
                                      color: contrastColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.list,
                                      color: contrastColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: buttonStyle.copyWith(
                                      alignment: Alignment.centerRight,
                                    ),
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.gear,
                                      color: contrastColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: x / 2,
                          )
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
