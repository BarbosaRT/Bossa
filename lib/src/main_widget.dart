import 'package:asuka/asuka.dart';
import 'package:bossa/src/audio/just_audio_manager.dart';
import 'package:bossa/src/audio/just_playlist_manager.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:localization/localization.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind((i) => ColorController()),
        Bind((i) => SettingsController()),
        Bind((i) => PlaylistUIController()),
        Bind((i) => HomeController()),
        Bind(
          (i) => JustPlaylistManager(),
        ),
        Bind(
          (i) => justAudioManagerInstance,
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
        // ignore: deprecated_member_use
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
    LocalJsonLocalization.delegate.directories = ['assets/i18n'];

    return MaterialApp.router(
      builder: Asuka.builder,
      localizationsDelegates: [
        // delegate from flutter_localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // delegate from localization package.
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }

        // define pt_BR as default when de language code is 'pt'
        if (locale?.languageCode == 'pt') {
          return const Locale('pt', 'BR');
        }

        // default language
        return const Locale('en', 'US');
      },
      debugShowCheckedModeBanner: false,
      title: 'Bossa',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
            trackVisibility: WidgetStateProperty.resolveWith((states) => true)),
        primarySwatch: colorController.currentCustomColor,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
