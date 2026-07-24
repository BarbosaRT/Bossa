import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/audio/just_audio_manager.dart';
import 'package:bossa/src/audio/just_playlist_manager.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/app_colors.dart';
import 'package:bossa/src/data/youtube/youtube_explode_parser.dart';
import 'package:bossa/src/data/youtube/piped_youtube_parser.dart';
import 'package:bossa/src/data/youtube/youtube_invidious_parser.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/ui/home/home_controller.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/player/player_page.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/material.dart' hide ThemeData;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:localization/localization.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(ColorController.new);
    i.addSingleton(SettingsController.new);
    i.addSingleton(PlaylistUIController.new);
    i.addSingleton(HomeController.new);
    i.add<PlaylistAudioManager>(JustPlaylistManager.new);
    i.add<AudioManager>(() => justAudioManagerInstance);
    i.add<DataManager>(() => dataManagerInstance);
    i.add<FilePath>(FilePathImpl.new);
    i.add<DownloadService>(() => HttpDownloadService(filePath: i<FilePath>()));
    i.add(SongDataManager.new);
    i.add(PlaylistDataManager.new);
    i.add<YoutubeParserInterface>(() {
      final settingsController = Modular.get<SettingsController>();
      final provider = settingsController.youTubeProvider;
      final instanceUrl = settingsController.providerInstanceUrl;
      switch (provider) {
        case 'invidious':
          return InvidiousYoutubeParser(
              serverUrl: instanceUrl.isNotEmpty ? instanceUrl : null);
        case 'piped':
          return PipedYoutubeParser(
              instanceUrl: instanceUrl.isNotEmpty ? instanceUrl : null);
        default:
          return YoutubeExplodeParser();
      }
    });
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => HomePage());
    r.child('/player', child: (context) => PlayerPage());
  }
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
    LocalJsonLocalization.delegate.directories = ['assets/i18n'];
    final colorController = Modular.get<ColorController>();
    final settingsController = Modular.get<SettingsController>();
    colorController.changeAccentColor(AccentColors.blueAccent);
    init();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    settingsController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void init() async {
    final colorController = Modular.get<ColorController>();
    final settingsController = Modular.get<SettingsController>();

    final prefs = await SharedPreferences.getInstance();

    // Load language settings
    await settingsController.loadLanguageSettings();

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
    //final colorController = Modular.get<ColorController>();
    final settingsController = Modular.get<SettingsController>();

    // Get the selected locale from settings
    Locale? selectedLocale;
    if (settingsController.selectedLanguageCode.isNotEmpty &&
        settingsController.selectedCountryCode.isNotEmpty) {
      selectedLocale = Locale(settingsController.selectedLanguageCode,
          settingsController.selectedCountryCode);
    }

    return ShadcnAnimatedTheme(
      data: ThemeData(
        colorScheme: ColorSchemes.darkSlate,
      ),
      duration: Duration(milliseconds: 300),
      child: MaterialApp.router(
        locale: selectedLocale, // Use the selected locale
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
          Locale('fr', 'FR'),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (supportedLocales.contains(locale)) {
            return locale;
          }

          // Check if we have a user-selected locale
          if (settingsController.selectedLanguageCode.isNotEmpty &&
              settingsController.selectedCountryCode.isNotEmpty) {
            Locale userLocale = Locale(settingsController.selectedLanguageCode,
                settingsController.selectedCountryCode);
            if (supportedLocales.contains(userLocale)) {
              return userLocale;
            }
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
        routerConfig: Modular.routerConfig,
      ),
    );
  }
}
