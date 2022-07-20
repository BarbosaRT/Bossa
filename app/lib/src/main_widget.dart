import 'package:bossa/src/features/audio/audio_page.dart';
import 'package:bossa/src/features/home/home_page.dart';
import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/files/load_controller.dart';
import 'package:bossa/src/features/files/save_controller.dart';
import 'package:bossa/src/features/files/file_page.dart';
import 'package:bossa/src/features/path/path_controller.dart';
import 'package:bossa/src/features/settings/settings_page.dart';
import 'package:bossa/src/features/splash/splash_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SplashNotifier()),
        ChangeNotifierProvider(create: (_) => PathNotifier()),
        ChangeNotifierProvider(create: (context) => LoadNotifier(pathNotifier: context.read())),
        ChangeNotifierProvider(create: (context) => SaveNotifier(pathNotifier: context.read(), loadNotifier: context.read())),
        ChangeNotifierProvider(create: (context) => FileNotifier(pathNotifier: context.read(), saveNotifier: context.read())),
        ChangeNotifierProvider(create: (context) => AudioNotifier(loadNotifier: context.read())),
      ], 
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/file': (context) => FilePage(),
        '/player' : (context) => const AudioPage(),
        }  
      ,)
    );
  }
}
