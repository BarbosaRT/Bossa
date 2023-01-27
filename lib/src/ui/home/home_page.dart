import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/home/components/player_widget.dart';
import 'package:bossa/src/ui/library/library_page.dart';
import 'package:bossa/src/ui/playlist/playlist_page.dart';
import 'package:bossa/src/ui/search/search_page.dart';
import 'package:bossa/src/ui/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeController extends ChangeNotifier {
  Pages _currentPage = Pages.home;
  Pages get currentPage => _currentPage;

  void setCurrentPage(Pages newPage) {
    _currentPage = newPage;
    notifyListeners();
  }

  PlaylistModel _currentPlaylist =
      PlaylistModel(id: 0, title: 'Todas as Musicas', icon: 'icon', songs: []);
  PlaylistModel get currentPlaylist => _currentPlaylist;

  void setPlaylist(PlaylistModel newPlaylist) {
    _currentPlaylist = newPlaylist;
    notifyListeners();
  }

  bool _searchLibrary = false;
  bool get searchLibrary => _searchLibrary;

  void setSearchLibrary(bool value) {
    _searchLibrary = value;
    notifyListeners();
  }

  String _lastSearchedTopic = '';
  String get lastSearchedTopic => _lastSearchedTopic;

  void setlastSearchedTopic(String value) {
    _lastSearchedTopic = value;
    notifyListeners();
  }
}

enum Pages { home, search, library, settings, playlist }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  Pages currentPage = Pages.home;
  Map<Pages, Widget> pageWidgets = {
    Pages.home: HomeWidget(key: UniqueKey()),
    Pages.library: LibraryPage(key: UniqueKey()),
    Pages.settings: SettingsPage(key: UniqueKey()),
    Pages.playlist: PlaylistPage(key: UniqueKey()),
    Pages.search: SearchPage(key: UniqueKey()),
  };

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
    currentPage = homeController.currentPage;
    homeController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            currentPage = homeController.currentPage;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    final homeController = Modular.get<HomeController>();
    homeController.addListener(() {
      if (mounted) {
        setState(() {
          currentPage = homeController.currentPage;
        });
      }
    });
    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );
    Widget widgetPage = pageWidgets[currentPage]!;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              widgetPage,
              //
              // Player Part
              //
              Positioned(
                bottom: x + iconSize / 2,
                left: x / 4,
                child: const PlayerWidget(),
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
                                    onPressed: () {
                                      homeController.setCurrentPage(Pages.home);
                                      setState(() {
                                        currentPage = Pages.home;
                                      });
                                    },
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
                                    onPressed: () {
                                      homeController.setSearchLibrary(false);
                                      homeController
                                          .setCurrentPage(Pages.search);
                                      setState(() {
                                        currentPage = Pages.search;
                                      });
                                    },
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
                                      homeController
                                          .setCurrentPage(Pages.library);
                                      setState(() {
                                        currentPage = Pages.library;
                                      });
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
                                      homeController
                                          .setCurrentPage(Pages.settings);
                                      setState(() {
                                        currentPage = Pages.settings;
                                      });
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
