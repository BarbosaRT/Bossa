import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/library/library_container.dart';
import 'package:bossa/src/ui/playlist/components/playlist_snackbar.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:text_scroll/text_scroll.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  PaletteGenerator? palette;
  bool gradient = true;
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();

  void updatePalette(String image) async {
    palette = await PaletteGenerator.fromImageProvider(
      ImageParser.getImageProviderFromString(image),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  PlaylistModel playlist =
      PlaylistModel(id: 0, title: 'Titulo', icon: 'icon', songs: []);

  @override
  void initState() {
    super.initState();

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    final homeController = Modular.get<HomeController>();
    playlist = PlaylistModel.fromMap(homeController.currentPlaylist.toMap());

    if (playlist.songs.isNotEmpty) {
      updatePalette(playlist.songs[0].icon);
    }

    final settingsController = Modular.get<SettingsController>();
    settingsController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            gradient = settingsController.gradientOnPlayer;
          });
        }
      });
    });
    homeController.addListener(() async {
      playlist = homeController.currentPlaylist;
      if (playlist.songs.isNotEmpty) {
        updatePalette(playlist.songs[0].icon);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentTheme.accentColor;
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    final titleStyle = TextStyles().boldHeadline.copyWith(color: contrastColor);
    final songDataManager = Modular.get<SongDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final homeController = Modular.get<HomeController>();
    final audioManager = playlistManager.player;

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    Color gradientColor = backgroundColor;
    if (palette != null) {
      gradientColor =
          gradient ? palette!.dominantColor!.color : backgroundColor;
    }

    List<Widget> songContainers = [];
    for (SongModel song in playlist.songs) {
      final index = playlist.songs.indexOf(song);
      final key = GlobalKey<DetailContainerState>();
      songContainers.add(
        LibraryContentContainer(
          title: song.title,
          author: song.author,
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
                    setState(() {});
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
                    Text('Remover ', style: buttonTextStyle),
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
                    Text('Editar ', style: buttonTextStyle),
                  ]),
                ),
              ),
            ],
            title: song.title,
          ),
          onTap: () {
            audioManager.pause();
            playlistUIController.setPlaylist(playlist, index: index);
            playlistManager.setPlaylist(playlist, initialIndex: index);
            Modular.to.pushReplacementNamed(
              '/player',
            );
          },
          icon: song.icon,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradientColor, backgroundColor],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: x / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: x / 2,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: ElevatedButton(
                          style: buttonStyle,
                          onPressed: () {
                            homeController.setCurrentPage(Pages.home);
                          },
                          child: FaIcon(
                            FontAwesomeIcons.angleLeft,
                            size: iconSize,
                            color: contrastColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image(
                            image: ImageParser.getImageProviderFromString(
                              playlist.icon,
                            ),
                            fit: BoxFit.cover,
                            alignment: FractionalOffset.center,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize * 1.5,
                        height: iconSize * 1.5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: x / 2,
                  ),
                  SizedBox(
                    width: size.width - x / 2,
                    height: 40,
                    child: TextScroll(
                      playlist.title,
                      mode: TextScrollMode.endless,
                      velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
                      delayBefore: const Duration(seconds: 10),
                      pauseBetween: const Duration(seconds: 5),
                      style: titleStyle,
                      textAlign: TextAlign.center,
                      selectable: true,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: iconSize * 1.5,
                        height: iconSize * 1.5,
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
                                return PlaylistSnackbar(playlist: playlist);
                              },
                            );
                          },
                          child: FaIcon(FontAwesomeIcons.ellipsisVertical,
                              color: contrastColor),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      SizedBox(
                        width: iconSize * 1.5,
                        child: ElevatedButton(
                          onPressed: () {
                            Modular.to.popUntil(ModalRoute.withName('/'));
                            audioManager.pause();
                            playlistUIController.setPlaylist(playlist);
                            playlistManager.setShuffleModeEnabled(true);
                            Modular.to.pushReplacementNamed(
                              '/player',
                            );
                            audioManager.play();
                          },
                          style: buttonStyle,
                          child: FaIcon(
                            FontAwesomeIcons.shuffle,
                            size: iconSize,
                            color: contrastColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 3 * iconSize / 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Modular.to.popUntil(ModalRoute.withName('/'));
                            audioManager.pause();
                            playlistUIController.setPlaylist(playlist);

                            Modular.to.pushReplacementNamed(
                              '/player',
                            );
                            audioManager.play();
                          },
                          style: buttonStyle,
                          child: FaIcon(
                            FontAwesomeIcons.solidCirclePlay,
                            size: iconSize * 1.5,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: x / 2,
                  ),
                  Expanded(
                    child: ListView(
                      children: songContainers,
                    ),
                  ),
                  SizedBox(
                    height: x * 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
