import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/content_container.dart';
import 'package:bossa/src/ui/home/home_controller.dart';
import 'package:bossa/src/ui/library/filter_widget.dart';
import 'package:bossa/src/ui/library/library_container.dart';
import 'package:bossa/src/ui/playlist/components/playlist_snackbar.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/song/song_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';
//import 'package:bossa/src/color/contrast_check.dart';
//import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  double iconSize = UIConsts.iconSize.toDouble();
  static double x = UIConsts.spacing;

  SongFilter _songFilter = SongFilter.idDesc;
  PlaylistFilter _playlistFilter = PlaylistFilter.idDesc;
  bool gridEnabled = false;

  late TabController _tabController;
  int currentTab = 0;
  //final ScrollController _scrollController = ScrollController();

  List<PlaylistModel> playlists = [];
  List<SongModel> songs = [];
  int index = 0;
  @override
  void initState() {
    super.initState();

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != currentTab && mounted) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });
    loadSongs();
    loadPlaylists();
  }

  void loadSongs() async {
    final songDataManager = Modular.get<SongDataManager>();
    songs = await songDataManager.loadAllSongs(filter: _songFilter);
    if (mounted) {
      setState(() {});
    }
  }

  void loadPlaylists() async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    playlists =
        await playlistDataManager.loadPlaylists(filter: _playlistFilter);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    // final accentColor = colorController.currentTheme.accentColor;
    // final backgroundColor = colorController.currentTheme.backgroundColor;
    // final backgroundAccent = colorController.currentTheme.backgroundAccent;

    final playlistManager = Modular.get<PlaylistAudioManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = Modular.get<AudioManager>();
    final homeController = Modular.get<HomeController>();

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    final textStyle = TextStyles().boldHeadline2.copyWith(color: contrastColor);

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );

    //const tabHeight = 50.0;

    List<Widget> songContainers = [];
    for (SongModel song in songs) {
      PlaylistModel playlist = PlaylistModel(
          id: 0,
          title: 'all-songs'.i18n(),
          icon: song.icon,
          songs: songs.toList());

      Widget detailContainer = SongSnackbar(
        song: song,
        callback: () {
          loadSongs();
        },
      );

      songContainers.add(
        gridEnabled
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContentContainer(
                    title: song.title,
                    author: song.author,
                    icon: song.icon,
                    imagesSize: size.width / 2 - x * 0.5,
                    textWidth: size.width / 2 - x * 1.75,
                    detailContainer: detailContainer,
                    onTap: () {
                      Modular.to.popUntil(ModalRoute.withName('/'));
                      audioManager.pause();

                      playlistUIController.setPlaylist(playlist,
                          index: songs.indexOf(song));
                      playlistManager.setPlaylist(playlist,
                          initialIndex: songs.indexOf(song));

                      Modular.to.pushReplacementNamed(
                        '/player',
                      );
                      audioManager.play();
                    }),
              )
            : LibraryContentContainer(
                title: song.title,
                author: song.author,
                detailContainer: detailContainer,
                onTap: () {
                  Modular.to.popUntil(ModalRoute.withName('/'));
                  audioManager.pause();

                  playlistUIController.setPlaylist(playlist,
                      index: songs.indexOf(song));
                  playlistManager.setPlaylist(playlist,
                      initialIndex: songs.indexOf(song));

                  Modular.to.pushReplacementNamed(
                    '/player',
                  );
                  audioManager.play();
                },
                icon: song.icon,
              ),
      );
    }

    List<Widget> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        gridEnabled
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContentContainer(
                    title: playlist.title,
                    author: '${playlist.songs.length} ${"songs".i18n()}',
                    icon: playlist.icon,
                    imagesSize: size.width / 2 - x * 0.5,
                    textWidth: size.width / 2 - x * 0.5,
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
                    }),
              )
            : LibraryContentContainer(
                title: playlist.title,
                author: '${playlist.songs.length} ${"songs".i18n()}',
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

    List<Widget> albumContainers = [];
    for (PlaylistModel playlist in playlists) {
      albumContainers.add(
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

    //bool isContrast = ContrastCheck().contrastCheck(accentColor, contrastColor);
    bool isHorizontal = size.width > size.height;
    //double width =
    //    isHorizontal ? size.width * (1 - UIConsts.leftBarRatio) : size.width;

    return SafeArea(
      child: ListView(
        children: [
          SizedBox(
            height: x / 2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: x / 2),
            child: Row(
              children: [
                Text('your-library'.i18n(), style: headerStyle),
                const Spacer(
                  flex: 1,
                ),
                SizedBox(
                  width: 3 * iconSize / 2,
                  height: 3 * iconSize / 2,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      homeController.setCurrentPage(Pages.search);
                      homeController.setSearchLibrary(true);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: contrastColor,
                      size: iconSize,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const AddWidget()
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: x / 2),
            child: SizedBox(
              height: 160,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Playlists', style: textStyle),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var playlist in albumContainers) playlist,
                        SizedBox(
                          width: x / 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: size.height - (isHorizontal ? 100 : 180),
            width: isHorizontal
                ? size.width * (1 - UIConsts.leftBarRatio)
                : size.width,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: x / 2, vertical: 8),
                  child: Row(
                    children: [
                      // FilterChip(
                      //   label: Text('songs'.i18n()),
                      //   selected: currentTab == 0,
                      //   selectedColor: accentColor,
                      //   checkmarkColor:
                      //       isContrast ? backgroundColor : contrastColor,
                      //   backgroundColor: backgroundAccent,
                      //   onSelected: (selected) {
                      //     if (selected) {
                      //       setState(() {
                      //         currentTab = 0;
                      //       });
                      //     }
                      //   },
                      // ),
                      // const SizedBox(width: 8),
                      // FilterChip(
                      //   label: Text('Playlist'.i18n()),
                      //   selected: currentTab == 1,
                      //   selectedColor: accentColor,
                      //   checkmarkColor:
                      //       isContrast ? backgroundColor : contrastColor,
                      //   backgroundColor: backgroundAccent,
                      //   onSelected: (selected) {
                      //     if (selected) {
                      //       setState(() {
                      //         currentTab = 1;
                      //       });
                      //     }
                      //   },
                      // ),

                      //
                      // Filters
                      //
                      FilterWidget(
                        isSong: currentTab == 0,
                        filterCallback: (v) {
                          if (currentTab == 0) {
                            _songFilter = v as SongFilter;
                            loadSongs();
                            return;
                          }
                          _playlistFilter = v as PlaylistFilter;
                          loadPlaylists();
                        },
                        gridCallback: (v) {
                          gridEnabled = v;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(currentTab),
                      padding: EdgeInsets.symmetric(horizontal: x / 2),
                      child: currentTab == 0
                          ? (gridEnabled
                              ? AlignedGridView.count(
                                  crossAxisCount: 2,
                                  itemCount: songContainers.length,
                                  itemBuilder: (context, index) {
                                    return songContainers[index];
                                  },
                                )
                              : ListView(
                                  children: songContainers,
                                ))
                          : (gridEnabled
                              ? AlignedGridView.count(
                                  crossAxisCount: 2,
                                  itemCount: playlistContainers.length,
                                  itemBuilder: (context, index) {
                                    return playlistContainers[index];
                                  },
                                )
                              : ListView(
                                  children: playlistContainers,
                                )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
