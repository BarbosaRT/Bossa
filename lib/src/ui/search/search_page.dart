import 'dart:async';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/contrast_checker.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/library/filter_widget.dart';
import 'package:bossa/src/ui/search/playlist_search.dart';
import 'package:bossa/src/ui/search/song_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final urlTextController = TextEditingController();
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();

  bool searchLibrary = false;
  bool isSearching = true;
  bool isSearchingSong = true;
  Duration delay = const Duration(milliseconds: 250);
  Timer searchTimer = Timer(const Duration(milliseconds: 250), () {});

  List<SongModel> songList = [];
  List<PlaylistModel> playlistList = [];

  List<Widget> songContainers = [];
  List<Widget> playlistContainers = [];

  String lastSearchQuery = '';
  SongFilter _songFilter = SongFilter.idDesc;
  PlaylistFilter _playlistFilter = PlaylistFilter.idDesc;
  bool gridEnabled = false;

  late TabController _tabController;
  int currentTab = 0;
  final ScrollController _scrollController = ScrollController();

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
      searchCommand(lastSearchQuery);
      if (_tabController.index != currentTab && mounted) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });

    final homeController = Modular.get<HomeController>();

    if (!searchLibrary) {
      urlTextController.text = homeController.lastSearchedTopic;
    } else {
      urlTextController.text = '';
    }
    homeController.addListener(() {
      searchLibrarySetter();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void searchLibrarySetter() {
    final homeController = Modular.get<HomeController>();
    searchLibrary = homeController.searchLibrary;
  }

  Future<void> search(String searchQuery) async {
    lastSearchQuery = searchQuery.toString();
    final homeController = Modular.get<HomeController>();

    if (!searchLibrary) {
      homeController.setlastSearchedTopic(searchQuery);
    }

    if (isSearchingSong) {
      songList = [];
    } else {
      playlistList = [];
    }

    if (isSearchingSong) {
      if (searchLibrary) {
        songList = await SongSearch().searchLibrary(
          searchQuery: searchQuery,
          filter: _songFilter,
        );
      } else {
        songList = await SongSearch().searchYoutube(
          searchQuery: searchQuery,
        );
      }
      loadSongs();
    } else {
      if (searchLibrary) {
        playlistList = await PlaylistSearch().searchLibrary(
          searchQuery: searchQuery,
          filter: _playlistFilter,
        );
      } else {
        playlistList = await PlaylistSearch().searchYoutube(
          searchQuery: searchQuery,
        );
      }
      loadPlaylists();
    }
  }

  Future<void> searchCommand(String searchQuery) async {
    if (mounted) {
      setState(() {
        isSearching = true;
      });
    }
    await search(searchQuery);
    if (mounted) {
      setState(() {
        isSearching = false;
      });
    }
  }

  void loadSongs() {
    songContainers = searchLibrary
        ? SongSearch().getLibraryWidgets(
            songs: songList,
            context: context,
            gridEnabled: gridEnabled,
          )
        : SongSearch().getYoutubeWidgets(
            songs: songList,
            context: context,
            gridEnabled: gridEnabled,
          );
    songContainers.add(
      SizedBox(
        height: 73 * 2 + x * 2,
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void loadPlaylists() {
    playlistContainers = searchLibrary
        ? PlaylistSearch().getLibraryWidgets(
            playlists: playlistList,
            context: context,
            gridEnabled: gridEnabled,
          )
        : PlaylistSearch().getYoutubeWidgets(
            playlists: playlistList,
            context: context,
            gridEnabled: gridEnabled,
          );
    playlistContainers.add(
      SizedBox(
        height: 73 * 2 + UIConsts.spacing,
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  //
  // Build
  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final homeController = Modular.get<HomeController>();
    if (homeController.searchLibrary != searchLibrary) {
      searchLibrarySetter();
      if (mounted) {
        setState(() {});
      }
    }

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final accentColor = colorController.currentTheme.accentColor;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);
    Widget songWidget = ListView(
      children: songContainers,
    );
    Widget playlistWidget = ListView(
      children: playlistContainers,
    );
    if (isSearching) {
      songWidget = ListView(
        children: [
          SizedBox(
            height: size.height / 3,
          ),
          const SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
      playlistWidget = ListView(
        children: [
          SizedBox(
            height: size.height / 3,
          ),
          const SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }
    if (gridEnabled) {
      songWidget = AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: songContainers.length,
        itemBuilder: (context, index) {
          return songContainers[index];
        },
      );

      playlistWidget = AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: playlistList.length,
        itemBuilder: (context, index) {
          return playlistContainers[index];
        },
      );
    }

    bool isContrast = ContrastCheck().contrastCheck(accentColor, contrastColor);
    double tabHeight = 50.0;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: x / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(left: x / 2),
                  child: Text(searchLibrary ? 'Buscar na Biblioteca' : 'Buscar',
                      style: headerStyle),
                ),
                SizedBox(
                  height: x / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(left: x / 2),
                  child: SizedBox(
                    width: size.width - x,
                    height: 40,
                    child: Container(
                      color: backgroundAccent,
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: urlTextController,
                        decoration: InputDecoration(
                          hintText: 'O que você quer ouvir?',
                          hintStyle: titleStyle,
                          isDense: true,
                          helperMaxLines: 1,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          icon: FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: contrastColor,
                          ),
                        ),
                        style: titleStyle,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (searchQuery) {
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () async {
                            searchCommand(searchQuery);
                          });
                        },
                        onSubmitted: (searchQuery) {
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () async {
                            searchCommand(searchQuery);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: x / 2,
                ),
                SizedBox(
                  height: size.height - 180,
                  width: size.width,
                  child: Stack(
                    children: [
                      NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool isScroll) {
                          return [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              pinned: true,
                              backgroundColor: backgroundColor,
                              bottom: PreferredSize(
                                preferredSize: Size.fromHeight(tabHeight),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: tabHeight * 0.5 + iconSize),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: backgroundAccent,
                                  ),
                                  child: TabBar(
                                    onTap: (value) {
                                      isSearchingSong = value == 0;
                                    },
                                    padding: EdgeInsets.zero,
                                    indicatorPadding: EdgeInsets.zero,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    labelPadding: EdgeInsets.zero,
                                    controller: _tabController,
                                    isScrollable: true,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.transparent,
                                        ),
                                      ],
                                    ),
                                    tabs: [
                                      Container(
                                        width: (size.width - x / 2) / 2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: _tabController.index == 0
                                              ? accentColor
                                              : backgroundAccent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Musicas',
                                            style: headerStyle.copyWith(
                                              color: (currentTab == 0 &&
                                                      isContrast)
                                                  ? backgroundColor
                                                  : contrastColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: (size.width - x / 2) / 2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: _tabController.index == 1
                                              ? accentColor
                                              : backgroundAccent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Playlist',
                                            style: headerStyle.copyWith(
                                              color: (currentTab == 1 &&
                                                      isContrast)
                                                  ? backgroundColor
                                                  : contrastColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ];
                        },
                        controller: _scrollController,
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            songWidget,
                            playlistWidget,
                          ],
                        ),
                      ),
                      //
                      // Filters
                      //
                      Positioned(
                        top: tabHeight + iconSize * 0.25,
                        left: UIConsts.spacing,
                        child: FilterWidget(
                          enableDropbutton: searchLibrary,
                          isSong: currentTab == 0,
                          filterCallback: (v) async {
                            if (currentTab == 0) {
                              _songFilter = v as SongFilter;
                            } else {
                              _playlistFilter = v as PlaylistFilter;
                            }
                            searchCommand(lastSearchQuery);
                          },
                          gridCallback: (v) async {
                            gridEnabled = v;
                            loadSongs();
                            loadPlaylists();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: x / 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
