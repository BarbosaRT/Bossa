import 'dart:io';

import 'package:asuka/asuka.dart';
import 'package:bossa/src/audio/just_audio_manager.dart';
import 'package:bossa/src/audio/just_playlist_manager.dart';
import 'package:bossa/src/audio/vlc_audio_manager.dart';
import 'package:bossa/src/audio/vlc_playlist_manager.dart';
import 'package:bossa/src/color/app_colors.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/player/player_page.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind((i) => ColorController()),
        Bind((i) => SettingsController()),
        Bind((i) => PlaylistUIController()),
        Bind((i) => HomeController()),
        Bind(
          (i) =>
              Platform.isLinux ? VlcPlaylistManager() : JustPlaylistManager(),
        ),
        Bind(
          (i) => Platform.isLinux
              ? vlcPlayerManagerInstance
              : justAudioManagerInstance,
        ),
        Bind((i) => FilePathImpl()),
        Bind(
          (i) => HttpDownloadService(
            filePath: i(),
          ),
        ),
        Bind(
          (i) => SongDataManager(
            localDataManagerInstance: dataManagerInstance,
            downloadService: i(),
          ),
        ),
        Bind(
          (i) => PlaylistDataManager(
            localDataManagerInstance: dataManagerInstance,
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const HomePage(),
        ),
        ChildRoute(
          '/player',
          child: (context, args) => const PlayerPage(),
        ),
      ];
}

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.changeAccentColor(AccentColors.blueAccent);
    init();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void init() async {
    final colorController = Modular.get<ColorController>();
    final settingsController = Modular.get<SettingsController>();

    final prefs = await SharedPreferences.getInstance();

    bool gradientOnPlayer = prefs.getBool('gradientOnPlayer') ?? true;
    settingsController.setGradientOnPlayer(gradientOnPlayer);

    int accentColor =
        prefs.getInt('accentColor') ?? colorController.currentAccent.value;
    colorController.changeAccentColor(Color(accentColor));

    int currentTheme = prefs.getInt('currentTheme') ??
        Themes().indexOf(colorController.currentTheme);
    if (currentTheme < 0) {
      currentTheme = 0;
    }
    colorController.changeTheme(Themes().themes[currentTheme]);
  }

  @override
  Widget build(BuildContext context) {
    Modular.setObservers([Asuka.asukaHeroController]);
    final colorController = Modular.get<ColorController>();
    return MaterialApp.router(
      builder: Asuka.builder,
      debugShowCheckedModeBanner: false,
      title: 'Bossa',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
            trackVisibility:
                MaterialStateProperty.resolveWith((states) => true)),
        primarySwatch: colorController.currentCustomColor,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
