import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/audio/playlist_ui_controller.dart';
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
import 'package:just_audio/just_audio.dart';
import 'package:text_scroll/text_scroll.dart';

enum Pages { home, search, list, config }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double x = 30.0;
  double iconSize = 25;

  List<SongModel> songs = [];
  List<PlaylistModel> playlists = [];

  final TextEditingController songTextController = TextEditingController();
  final TextEditingController playlistTextController = TextEditingController();

  final popupStyle = GoogleFonts.poppins(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    loadSongs();
    loadPlaylists();
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
    required String addText,
    required String fromYoutubeText,
    required String fromFileText,
    required Widget addWidget,
    required Widget urlWidget,
    void Function()? whenExit,
  }) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

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
                            return SizedBox(
                              width: size.width,
                              height: 100,
                              child: Column(
                                children: [
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        whenExit?.call();
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
                                          padding: EdgeInsets.symmetric(
                                              vertical: x / 2,
                                              horizontal: x / 2),
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
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: x),
                                      child: urlWidget),
                                ],
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

  Widget contentContainer(
      {required String icon,
      required void Function() remove,
      required void Function() onTap}) {
    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;
    return Padding(
      padding: EdgeInsets.only(right: x / 3),
      child: GestureDetector(
        onTap: onTap,
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
                    onPressed: remove,
                    child: FaIcon(
                      FontAwesomeIcons.trash,
                      size: iconSize,
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
            icon,
          ),
          fit: BoxFit.cover,
          alignment: FractionalOffset.center,
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final contrastAccent = colorController.currentScheme.contrastAccent;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final textStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 28, fontWeight: FontWeight.normal);

    final headerStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 28, fontWeight: FontWeight.bold);

    final titleStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 15, fontWeight: FontWeight.bold);

    final authorStyle = GoogleFonts.poppins(
        color: contrastAccent, fontSize: 10, fontWeight: FontWeight.normal);

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    Stream<bool> playingStream = playlistManager.player.playingStream;
    Stream<SequenceState?> songsStream =
        playlistManager.player.sequenceStateStream;

    List<Widget> songContainers = [];
    for (SongModel song in songs) {
      List<SongModel> songsForPlaylist = songs.toList();
      songsForPlaylist.remove(song);
      songsForPlaylist.insert(0, song);
      PlaylistModel playlist = PlaylistModel(
          id: 0,
          title: 'Todas as Músicas',
          icon: song.icon,
          songs: songsForPlaylist);
      songContainers.add(
        contentContainer(
          onTap: () {
            Modular.to.popUntil(ModalRoute.withName('/'));
            audioManager.pause();
            playlistUIController.setPlaylist(playlist);
            Modular.to.pushReplacementNamed(
              '/player',
              arguments: playlist,
            );
          },
          icon: song.icon,
          remove: () async {
            songDataManager.removeSong(song);
            loadSongs();
          },
        ),
      );
    }

    List<Widget> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        contentContainer(
          onTap: () {
            Modular.to.popUntil(ModalRoute.withName('/'));
            audioManager.pause();
            playlistUIController.setPlaylist(playlist);
            Modular.to.pushReplacementNamed(
              '/player',
              arguments: playlist,
            );
          },
          icon: playlist.icon,
          remove: () async {
            playlistDataManager.deletePlaylist(playlist);
            loadPlaylists();
          },
        ),
      );
    }

    final addSongWidget = addWidget(
      addWidget: SizedBox(
        width: size.width,
        height: 250,
        child: SongAddWidget(
          callback: loadSongs,
        ),
      ),
      whenExit: () {
        songTextController.text = '';
      },
      fromYoutubeText: 'Song From Youtube',
      fromFileText: 'Song from File',
      addText: 'Add Song',
      urlWidget: Row(
        children: [
          Expanded(
            child: TextField(
              controller: songTextController,
              decoration:
                  InputDecoration(hintText: 'Url', hintStyle: popupStyle),
              style: popupStyle,
              onChanged: (value) {
                songTextController.text = value.toString();
              },
              onSubmitted: (value) {
                songTextController.text = value.toString();
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final youtubeParser =
                  YoutubeParser(songDataManager: songDataManager);
              String url = songTextController.text.toString();
              SongModel song = await youtubeParser.convertYoutubeSong(url);
              songDataManager.addSong(song);
              loadSongs();
              songTextController.text = '';
            },
            child: FaIcon(
              FontAwesomeIcons.plus,
              size: iconSize,
            ),
          ),
        ],
      ),
    );

    final addPlaylistWidget = addWidget(
      addWidget: SizedBox(
        width: size.width,
        height: 320,
        child: PlaylistAddWidget(
          callback: loadPlaylists,
        ),
      ),
      whenExit: () {
        playlistTextController.text = '';
      },
      fromYoutubeText: 'Playlist From Youtube',
      fromFileText: 'Create a New Playlist',
      addText: 'Add Playlist',
      urlWidget: Row(
        children: [
          Expanded(
            child: TextField(
              controller: playlistTextController,
              decoration:
                  InputDecoration(hintText: 'Url', hintStyle: popupStyle),
              style: popupStyle,
              onChanged: (value) {
                playlistTextController.text = value.toString();
              },
              onSubmitted: (value) {
                playlistTextController.text = value.toString();
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final youtubeParser =
                  YoutubeParser(songDataManager: songDataManager);

              PlaylistModel playlist = await youtubeParser
                  .convertYoutubePlaylist(playlistTextController.text);

              playlistDataManager.addPlaylist(playlist);
              loadPlaylists();
              playlistTextController.text = '';
            },
            child: FaIcon(
              FontAwesomeIcons.plus,
              size: iconSize,
            ),
          ),
        ],
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
              Positioned(
                right: x / 2,
                child: SizedBox(
                  width: 3 * iconSize / 2,
                  height: 3 * iconSize / 2,
                  child: ElevatedButton(
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
                      size: iconSize,
                    ),
                  ),
                ),
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
              // Player Part
              //
              Positioned(
                bottom: x + iconSize / 2,
                left: x / 4,
                child: StreamBuilder<bool>(
                    stream: playingStream,
                    builder: (context, snapshot) {
                      bool playing =
                          snapshot.data != null ? snapshot.data! : false;
                      return playlistUIController.hasPlayedOnce
                          ? StreamBuilder<SequenceState?>(
                              stream: songsStream,
                              builder: (context, snapshot) {
                                SongModel currentSong =
                                    playlistUIController.playlist.songs[0];
                                SequenceState? state = snapshot.data;
                                if (state != null) {
                                  currentSong = playlistUIController
                                      .playlist.songs[state.currentIndex];
                                }
                                return GestureDetector(
                                  onTap: () {
                                    Modular.to.pop();
                                  },
                                  child: Container(
                                    height: 70,
                                    width: size.width - x / 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: backgroundAccent,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: x / 2, horizontal: x / 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image(
                                                image: ImageParser
                                                    .getImageProviderFromString(
                                                  currentSong.icon,
                                                ),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.fill,
                                              ),
                                              SizedBox(
                                                width: x / 4,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: size.width - x * 7,
                                                    height: 20,
                                                    child: TextScroll(
                                                      currentSong.title,
                                                      mode: TextScrollMode
                                                          .endless,
                                                      velocity: const Velocity(
                                                          pixelsPerSecond:
                                                              Offset(100, 0)),
                                                      delayBefore:
                                                          const Duration(
                                                              seconds: 10),
                                                      pauseBetween:
                                                          const Duration(
                                                              seconds: 5),
                                                      style: titleStyle,
                                                      textAlign:
                                                          TextAlign.right,
                                                      selectable: true,
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   currentSong.title,
                                                  //   style: titleStyle,
                                                  // ),
                                                  Text(
                                                    currentSong.author,
                                                    style: authorStyle,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 3 * iconSize / 2,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    playing
                                                        ? audioManager.pause()
                                                        : audioManager.play();
                                                  },
                                                  style: buttonStyle,
                                                  child: FaIcon(
                                                    playing
                                                        ? FontAwesomeIcons
                                                            .solidCirclePause
                                                        : FontAwesomeIcons
                                                            .solidCirclePlay,
                                                    size: iconSize * 1.5,
                                                    color: contrastColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: x / 2,
                                              ),
                                              SizedBox(
                                                width: 3 * iconSize / 2,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    playlistManager
                                                        .seekToNext();
                                                  },
                                                  style: buttonStyle,
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .forwardStep,
                                                    size: iconSize,
                                                    color: contrastColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                          : Container();
                    }),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  height: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.house,
                                      color: contrastColor,
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  height: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {},
                                    child: FaIcon(
                                      FontAwesomeIcons.magnifyingGlass,
                                      color: contrastColor,
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  height: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {
                                      //playlistDataManager.deleteAll();
                                      loadPlaylists();
                                    },
                                    child: FaIcon(
                                      FontAwesomeIcons.list,
                                      color: contrastColor,
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  height: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    style: buttonStyle,
                                    onPressed: () {
                                      //songDataManager.deleteAll();
                                      loadSongs();
                                    },
                                    child: FaIcon(
                                      FontAwesomeIcons.gear,
                                      color: contrastColor,
                                      size: iconSize,
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
