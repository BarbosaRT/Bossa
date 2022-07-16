import 'dart:io';

import 'package:bossa/app/colors/app_colors.dart';
import 'package:bossa/app/controllers/home_controller.dart';
import 'package:bossa/app/pages/file_page.dart';
import 'package:bossa/app/pages/home_page.dart';
import 'package:bossa/app/pages/loading_page.dart';
import 'package:bossa/app/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AppController extends StatefulWidget {
  const AppController({Key? key}) : super(key: key);

  @override
  State<AppController> createState() => AppControllerState();
}

class AppControllerState extends State<AppController> {
  Directory dir = Directory('');
  HomeController homeController = HomeController();
  FilePage filePage = FilePage();
  LoadingPage loadingPage = const LoadingPage();
  bool isDark = true;
  late SettingsPage settingsPage;

  void changeTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  void homeStyle(String selectedScreen) {
    homeController.screen = selectedScreen;
  }

  @override
  void initState() {
    super.initState();
    settingsPage = SettingsPage(appController: this);
  }

  void localPath() async {
    await getApplicationDocumentsDirectory().then((value) {
      dir = value;
      homeController.dir = dir;
      filePage.dir = dir;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = AppTheme()..isDark = isDark;

    // Loads the directory
    localPath();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme.themeData,
      initialRoute: '/loading',
      routes: {
        '/': (context) => homeController,
        '/file': (context) => filePage,
        '/loading': (context) => loadingPage,
        '/settings': (context) => settingsPage,
      },
    );
  }
}
