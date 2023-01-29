import 'package:asuka/asuka.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/content_container.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/playlist/add_to_playlist_page.dart';
import 'package:bossa/src/ui/playlist/components/playlist_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:bossa/src/url/youtube_url_add_page.dart';

class AddWidget extends StatefulWidget {
  const AddWidget({super.key});

  @override
  State<AddWidget> createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  double iconSize = UIConsts.iconSize.toDouble();
  static double x = UIConsts.spacing;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget addWidget({
    required String addText,
    required String fromYoutubeText,
    required String fromFileText,
    required void Function(BuildContext ctx) onFilePress,
    required void Function(BuildContext ctx) onYoutubePress,
  }) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final contrastColor = colorController.currentTheme.contrastColor;

    final popupStyle = TextStyles().headline2.copyWith(color: contrastColor);

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
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;

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

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  double imagesSize = 100;

  List<SongModel> songs = [];
  List<SongModel> songsSortedByTimesPlayed = [];
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
    songsSortedByTimesPlayed = await songDataManager.loadAllSongs(
      filter: SongFilter.timesPlayedDesc,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void loadPlaylists() async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    playlists = await playlistDataManager.loadPlaylists();
    if (mounted) {
      setState(() {});
    }
  }

  Widget songContainerBuilder(
      SongModel song, PlaylistModel playlistToBePlayed) {
    final size = MediaQuery.of(context).size;
    final songDataManager = Modular.get<SongDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final audioManager = playlistManager.player;
    final buttonStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    final key = GlobalKey<DetailContainerState>();

    return ContentContainer(
      detailContainer: DetailContainer(
        icon: song.icon,
        key: key,
        actions: [
          SizedBox(
            width: size.width,
            height: 30,
            child: GestureDetector(
              onTap: () {
                key.currentState?.pop();
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
                Text('Remover', style: buttonStyle),
              ]),
            ),
          ),
          SizedBox(
            width: size.width,
            height: 30,
            child: GestureDetector(
              onTap: () {
                key.currentState?.pop();
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
                Text('Editar', style: buttonStyle),
              ]),
            ),
          ),
          SizedBox(
            width: size.width,
            height: 30,
            child: GestureDetector(
              onTap: () {
                key.currentState?.pop();
                Modular.to.push(
                  MaterialPageRoute(
                    builder: (context) => AddToPlaylistPage(
                      song: song,
                    ),
                  ),
                );
              },
              child: Row(children: [
                FaIcon(
                  FontAwesomeIcons.circlePlus,
                  size: iconSize,
                  color: contrastColor,
                ),
                SizedBox(
                  width: iconSize / 2,
                ),
                Text('Adicionar à playlist', style: buttonStyle),
              ]),
            ),
          ),
        ],
        title: song.title,
      ),
      onTap: () {
        Modular.to.popUntil(ModalRoute.withName('/'));
        audioManager.pause();

        playlistUIController.setPlaylist(playlistToBePlayed,
            index: playlistToBePlayed.songs.indexOf(song));
        playlistManager.setPlaylist(playlistToBePlayed,
            initialIndex: playlistToBePlayed.songs.indexOf(song));

        Modular.to.pushReplacementNamed(
          '/player',
        );
        audioManager.play();
      },
      icon: song.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final homeController = Modular.get<HomeController>();

    final textStyle = TextStyles().headline.copyWith(color: contrastColor);

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);

    List<Widget> songContainers = [];
    for (SongModel song in songs) {
      PlaylistModel playlist = PlaylistModel(
          id: 0,
          title: 'Todas as Músicas',
          icon: song.icon,
          songs: songs.toList());
      songContainers.add(songContainerBuilder(song, playlist));
    }

    List<Widget> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        ContentContainer(
          detailContainer: PlaylistSnackbar(
            playlist: playlist,
            callback: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
          onTap: () {
            homeController.setPlaylist(playlist);
            if (mounted) {
              setState(() {
                homeController.setCurrentPage(Pages.playlist);
              });
            }
          },
          icon: playlist.icon,
        ),
      );
    }

    List<Widget> songsSortedWidgets = [];
    for (SongModel song in songsSortedByTimesPlayed) {
      List<SongModel> songsForPlaylist = songsSortedByTimesPlayed.toList();
      songsForPlaylist.remove(song);
      songsForPlaylist.insert(0, song);
      PlaylistModel playlist = PlaylistModel(
          id: 0,
          title: 'Todas as Músicas',
          icon: song.icon,
          songs: songsForPlaylist);
      songsSortedWidgets.add(songContainerBuilder(song, playlist));
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
                    SizedBox(
                      height: 160,
                      width: size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Músicas mais ouvidas',
                            style: textStyle,
                            maxLines: 2,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: songsSortedWidgets,
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
