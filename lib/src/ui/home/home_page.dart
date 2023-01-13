import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/ui/file/song_add_page.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/test/song_container.dart';
import 'package:bossa/src/url/download_service.dart';
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

  final songDataManager = SongDataManager(
    localDataManagerInstance: dataManagerInstance,
    downloadService: DioDownloadService(
      filePath: FilePathImpl(),
    ),
  );

  final playlistDataManager =
      PlaylistDataManager(localDataManagerInstance: dataManagerInstance);

  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void loadSongs() async {
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;

    final textStyle = GoogleFonts.poppins(
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
        Image(
          image: ImageParser.getImageProviderFromString(song.icon),
          width: 100,
          height: 100,
        ),
      );
    }

    final addSongWidget = ElevatedButton(
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
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: x / 2,
                                  ),
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
                                  SizedBox(
                                    width: x / 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Song From Youtube',
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
                              height: 220,
                              child: SongAddPage(
                                callback: loadSongs,
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Song From a File',
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
        'Add Song',
        style: popupStyle,
      ),
    );

    final addPlaylistWidget = ElevatedButton(
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
                      onPressed: () {},
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
                  Text('Bem-vindo', style: textStyle),
                ],
              ),
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
                                children: [addSongWidget, addPlaylistWidget],
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
                  SizedBox(
                    width: x / 2 - 3,
                  ),
                ],
              ),
              Positioned(
                top: 100,
                left: x / 2,
                child: SizedBox(
                  height: 250,
                  child: Column(
                    children: [
                      Text('Recem Adicionados', style: textStyle),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: songContainers,
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
