// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:bossa/src/url/url_add_page.dart';
import 'package:text_scroll/text_scroll.dart';

class AddWidget extends StatefulWidget {
  const AddWidget({super.key});

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  double iconSize = 25;
  static double x = 30;
  final popupStyle = GoogleFonts.poppins(
      color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal);

  Widget addWidget({
    required String addText,
    required String fromYoutubeText,
    required String fromFileText,
    required void Function(BuildContext ctx) onFilePress,
    required void Function(BuildContext ctx) onYoutubePress,
  }) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;

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
                        onYoutubePress(context);
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
    final addSongWidget = addWidget(
      onFilePress: (BuildContext ctx) {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => const SongAddPage(),
          ),
        );
      },
      addText: 'Adicionar música',
      fromYoutubeText: 'Adicionar música do Youtube',
      fromFileText: 'Adicionar música de um arquivo',
      onYoutubePress: (ctx) {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => const YoutubeUrlAddPage(
              isSong: true,
            ),
          ),
        );
      },
    );

    final addPlaylistWidget = addWidget(
      onFilePress: (ctx) {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => const PlaylistAddPage(),
          ),
        );
      },
      addText: 'Adicionar playlist',
      fromYoutubeText: 'Adicionar playlist do Youtube',
      fromFileText: 'Criar uma nova playlist',
      onYoutubePress: (ctx) {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pop();
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => const YoutubeUrlAddPage(
              isSong: false,
            ),
          ),
        );
      },
    );
    return SizedBox(
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
    );
  }
}

class ContentContainer extends StatefulWidget {
  final DetailContainer detailContainer;
  final String icon;
  final void Function() onTap;

  const ContentContainer({
    super.key,
    required this.icon,
    required this.detailContainer,
    required this.onTap,
  });

  @override
  State<ContentContainer> createState() => _ContentContainerState();
}

class _ContentContainerState extends State<ContentContainer> {
  static double x = 30;
  double iconSize = 25;
  double imagesSize = 100;

  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;

    return Padding(
      padding: EdgeInsets.only(right: x / 3),
      child: GestureDetector(
        onTap: widget.onTap,
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
              return widget.detailContainer;
            },
          );
        },
        child: Image(
          image: ImageParser.getImageProviderFromString(
            widget.icon,
          ),
          fit: BoxFit.cover,
          alignment: FractionalOffset.center,
          width: imagesSize,
          height: imagesSize,
        ),
      ),
    );
  }
}

class DetailContainer extends StatefulWidget {
  final String icon;
  final String title;
  final List<Widget> actions;
  const DetailContainer({
    Key? key,
    required this.icon,
    required this.title,
    required this.actions,
  }) : super(key: key);

  @override
  State<DetailContainer> createState() => _DetailContainerState();
}

class _DetailContainerState extends State<DetailContainer> {
  static double x = 30;
  double iconSize = 25;
  double imagesSize = 100;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final titleStyle = TextStyles().headline.copyWith(color: contrastColor);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: x),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image(
            image: ImageParser.getImageProviderFromString(
              widget.icon,
            ),
            fit: BoxFit.cover,
            alignment: FractionalOffset.center,
            width: imagesSize,
            height: imagesSize,
          ),
          SizedBox(
            width: size.width,
            child: TextScroll(
              widget.title,
              mode: TextScrollMode.endless,
              velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
              delayBefore: const Duration(seconds: 10),
              pauseBetween: const Duration(seconds: 5),
              style: titleStyle,
              textAlign: TextAlign.center,
              selectable: true,
            ),
          ),
          for (Widget action in widget.actions) action
        ],
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  static double x = 30.0;
  double iconSize = 25;
  double imagesSize = 100;

  List<SongModel> songs = [];
  List<PlaylistModel> playlists = [];

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;

    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;

    final textStyle = TextStyles().headline.copyWith(color: contrastColor);

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);

    final buttonStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

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
        ContentContainer(
          detailContainer: DetailContainer(
            icon: song.icon,
            actions: [
              SizedBox(
                width: size.width,
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    songDataManager.removeSong(song);
                    loadSongs();
                  },
                  child: Row(children: [
                    FaIcon(
                      FontAwesomeIcons.trash,
                      size: iconSize,
                      color: contrastColor,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    Text('Remover ', style: buttonStyle),
                  ]),
                ),
              ),
              SizedBox(
                width: size.width,
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Modular.to.push(
                      MaterialPageRoute(
                        builder: (context) => SongAddPage(
                          songToBeEdited: song,
                        ),
                      ),
                    );
                  },
                  child: Row(children: [
                    FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: iconSize,
                      color: contrastColor,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    Text('Editar ', style: buttonStyle),
                  ]),
                ),
              ),
            ],
            title: song.title,
          ),
          onTap: () {
            Modular.to.popUntil(ModalRoute.withName('/'));
            audioManager.pause();
            playlistUIController.setPlaylist(playlist);
            Modular.to.pushReplacementNamed(
              '/player',
            );
          },
          icon: song.icon,
        ),
      );
    }

    List<Widget> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        ContentContainer(
          detailContainer: DetailContainer(
            icon: playlist.icon,
            title: playlist.title,
            actions: [
              SizedBox(
                width: size.width,
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    playlistDataManager.deletePlaylist(playlist);
                    loadPlaylists();
                  },
                  child: Row(children: [
                    FaIcon(
                      FontAwesomeIcons.trash,
                      size: iconSize,
                      color: contrastColor,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    Text('Remover ', style: buttonStyle),
                  ]),
                ),
              ),
              SizedBox(
                width: size.width,
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Modular.to.push(
                      MaterialPageRoute(
                        builder: (context) => PlaylistAddPage(
                          playlistToBeEdited: playlist,
                        ),
                      ),
                    );
                  },
                  child: Row(children: [
                    FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: iconSize,
                      color: contrastColor,
                    ),
                    SizedBox(
                      width: iconSize / 2,
                    ),
                    Text('Editar ', style: buttonStyle),
                  ]),
                ),
              ),
            ],
          ),
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
        ),
      );
    }

    return SafeArea(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Positioned(
              top: x / 2,
              child: Row(
                children: [
                  SizedBox(
                    width: x / 2,
                  ),
                  Text('Bem-vindo', style: headerStyle),
                ],
              ),
            ),
            //
            // Plus Button
            //
            Positioned(top: x / 2, right: x / 2, child: const AddWidget()),
            //
            // Home List
            //
            Positioned(
              top: 50 + x / 2,
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
