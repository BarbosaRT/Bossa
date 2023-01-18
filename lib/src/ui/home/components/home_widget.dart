import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/home/components/playlist_add_widget.dart';
import 'package:bossa/src/ui/home/components/song_add_widget.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/audio/playlist_ui_controller.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  static double x = 30.0;
  double iconSize = 25;
  double imagesSize = 100;
  bool cropImages = true;

  List<SongModel> songs = [];
  List<PlaylistModel> playlists = [];

  final TextEditingController songTextController = TextEditingController();
  final TextEditingController playlistTextController = TextEditingController();

  final popupStyle = GoogleFonts.poppins(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    final settingsController = Modular.get<SettingsController>();
    settingsController.addListener(
      () {
        setState(() {
          cropImages = settingsController.cropImages;
        });
      },
    );

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
    required void Function(BuildContext ctx) onFilePress,
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
                        onFilePress(context);
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
      required void Function(BuildContext ctx) edit,
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
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: x),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: remove,
                      child: FaIcon(
                        FontAwesomeIcons.trash,
                        size: iconSize,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        edit(context);
                      },
                      child: FaIcon(
                        FontAwesomeIcons.penToSquare,
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: cropImages ? 0.75 : 1,
            widthFactor: cropImages ? 0.75 : 1,
            child: Image(
              image: ImageParser.getImageProviderFromString(
                icon,
              ),
              fit: BoxFit.cover,
              alignment: FractionalOffset.center,
              width: cropImages ? imagesSize * 1.25 : imagesSize,
              height: cropImages ? imagesSize * 1.25 : imagesSize,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;

    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;

    final textStyle = TextStyles().headline.copyWith(color: contrastColor);

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);

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
          edit: (BuildContext ctx) {
            Navigator.of(ctx).pop();
            Modular.to.push(
              MaterialPageRoute(
                builder: (context) => SongAddPage(
                  songToBeEdited: song,
                ),
              ),
            );
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
          edit: (ctx) {
            Navigator.of(ctx).pop();
            Modular.to.push(
              MaterialPageRoute(
                builder: (context) => PlaylistAddPage(
                  playlistToBeEdited: playlist,
                  callback: loadPlaylists,
                ),
              ),
            );
          },
        ),
      );
    }

    final addSongWidget = addWidget(
      onFilePress: (BuildContext ctx) {
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => const SongAddPage(),
          ),
        );
      },
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
      onFilePress: (ctx) {
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => PlaylistAddPage(
              callback: loadPlaylists,
            ),
          ),
        );
      },
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

    return SafeArea(
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
          ],
        ),
      ),
    );
  }
}
