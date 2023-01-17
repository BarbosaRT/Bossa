import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/home/components/player_widget.dart';
import 'package:bossa/src/ui/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Pages { home, search, library, settings }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double x = 30.0;
  double iconSize = 25;
  Pages currentPage = Pages.home;

  Widget returnPage() {
    switch (currentPage) {
      case Pages.settings:
        return const SettingsPage();
      default:
        return const HomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    Widget widgetPage = returnPage();

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
                  child: const PlayerWidget()),
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
