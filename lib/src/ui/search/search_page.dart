import 'dart:async';
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
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
      songContainers = [];
    } else {
      playlistContainers = [];
    }

    if (isSearchingSong) {
      if (searchLibrary) {
        songContainers = await SongSearch().searchLibrary(
          searchQuery: searchQuery,
          context: context,
          filter: _songFilter,
          gridEnabled: gridEnabled,
        );
      } else {
        songContainers = await SongSearch().searchYoutube(
          searchQuery: searchQuery,
          context: context,
          gridEnabled: gridEnabled,
        );
      }
      songContainers.add(
        SizedBox(
          height: 73 * 2 + x * 2,
        ),
      );
    } else {
      if (searchLibrary) {
        playlistContainers = await PlaylistSearch().searchLibrary(
          searchQuery: searchQuery,
          context: context,
          filter: _playlistFilter,
          gridEnabled: gridEnabled,
        );
      } else {
        playlistContainers = await PlaylistSearch().searchYoutube(
          searchQuery: searchQuery,
          context: context,
          gridEnabled: gridEnabled,
        );
      }
      playlistContainers.add(
        SizedBox(
          height: 73 * 2 + UIConsts.spacing,
        ),
      );
    }

    if (mounted) {
      setState(() {});
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

  //
  // Build
  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final homeController = Modular.get<HomeController>();
    if (homeController.searchLibrary != searchLibrary) {
      searchLibrarySetter();
      setState(() {});
    }

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final accentColor = colorController.currentScheme.accentColor;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);

    Widget songWidget = Column(
      children: [
        SizedBox(
          height: size.height / 3,
        ),
        const CircularProgressIndicator(),
      ],
    );
    Widget playlistWidget = Column(
      children: [
        SizedBox(
          height: size.height / 3,
        ),
        const CircularProgressIndicator(),
      ],
    );
    if (!isSearching) {
      songWidget = ListView(
        children: songContainers,
      );
      playlistWidget = ListView(
        children: playlistContainers,
      );
      if (searchLibrary || gridEnabled) {
        songWidget = AlignedGridView.count(
          crossAxisCount: 2,
          itemCount: songContainers.length,
          itemBuilder: (context, index) {
            return songContainers[index];
          },
        );

        playlistWidget = AlignedGridView.count(
          crossAxisCount: 2,
          itemCount: playlistContainers.length,
          itemBuilder: (context, index) {
            return playlistContainers[index];
          },
        );
      }
    }

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
                                      setState(() {});
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
                                            style: headerStyle,
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
                                            style: headerStyle,
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
                            searchCommand(lastSearchQuery);
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
