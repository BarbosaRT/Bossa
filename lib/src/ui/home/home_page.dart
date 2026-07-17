import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/home/components/player_widget.dart';
import 'package:bossa/src/ui/home/components/window_buttons.dart';
import 'package:bossa/src/ui/home/home_controller.dart';
import 'package:bossa/src/ui/library/library_page.dart';
import 'package:bossa/src/ui/playlist/playlist_page.dart';
import 'package:bossa/src/ui/search/search_page.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/src/ui/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

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

  Duration transitionDuration = const Duration(milliseconds: 100);
  Duration transitionWait = const Duration(milliseconds: 100);
  bool transition = false;
  bool gradient = true;

  @override
  void initState() {
    super.initState();
    final settingsController = Modular.get<SettingsController>();
    gradient = settingsController.gradient;
    settingsController.addListener(() {
      gradient = settingsController.gradient;
      if (mounted) {
        setState(() {});
      }
    });

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    final homeController = Modular.get<HomeController>();
    currentPage = homeController.currentPage;
    homeController.addListener(() {
      currentPage = homeController.currentPage;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void makeTransition(Pages newPage) {
    final homeController = Modular.get<HomeController>();
    if (mounted) {
      setState(() {
        transition = true;
      });
    }
    Future.delayed(Duration(
      milliseconds:
          transitionDuration.inMilliseconds + transitionWait.inMilliseconds,
    )).then((value) {
      homeController.setCurrentPage(newPage);
      transition = false;
      if (mounted) {
        setState(() {
          currentPage = newPage;
        });
      }
    });
  }

  Widget getIcon(Widget icon, String text) {
    final size = MediaQuery.of(context).size;
    bool isHorizontal = size.width > size.height;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final textStyle = TextStyles().headline2.copyWith(color: contrastColor);
    return isHorizontal
        ? Row(
            children: [
              icon,
              const SizedBox(
                width: 5,
              ),
              Text(
                text,
                style: textStyle,
              )
            ],
          )
        : icon;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final homeController = Modular.get<HomeController>();

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final accentColor = colorController.currentTheme.accentColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );

    Widget widgetPage = AnimatedOpacity(
      duration: transitionDuration,
      opacity: transition ? 0 : 1,
      child: pageWidgets[currentPage]!,
    );

    bool isHorizontal = size.width > size.height;

    final buttons = [
      SizedBox(
        height: 3 * iconSize / 2,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: () {
            makeTransition(Pages.home);
          },
          child: getIcon(
            FaIcon(
              FontAwesomeIcons.house,
              color: contrastColor,
              size: iconSize,
            ),
            'begin'.i18n(),
          ),
        ),
      ),
      SizedBox(
        height: 3 * iconSize / 2,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: () {
            homeController.setSearchLibrary(false);
            makeTransition(Pages.search);
          },
          child: getIcon(
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: contrastColor,
              size: iconSize,
            ),
            'search'.i18n(),
          ),
        ),
      ),
      SizedBox(
        height: 3 * iconSize / 2,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: () {
            makeTransition(Pages.library);
          },
          child: getIcon(
            FaIcon(
              FontAwesomeIcons.list,
              color: contrastColor,
              size: iconSize,
            ),
            'your-library'.i18n(),
          ),
        ),
      ),
      SizedBox(
        height: 3 * iconSize / 2,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: () {
            makeTransition(Pages.settings);
          },
          child: getIcon(
            FaIcon(
              FontAwesomeIcons.gear,
              color: contrastColor,
              size: iconSize,
            ),
            'config'.i18n(),
          ),
        ),
      ),
    ];

    final double leftBarWidth = 200;
    final double topPadding = 31;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            WindowTitleBarBox(
              child: WindowButtons(),
            ),
            //
            // Widget Page
            //
            isHorizontal
                ? SizedBox(
                    height: size.height,
                    width: size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: leftBarWidth,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPadding,
                              bottom: 100,
                              left: UIConsts.spacing,
                              right: UIConsts.spacing / 2,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: contrastColor.withValues(alpha: .05),
                                  borderRadius: BorderRadius.circular(20)),
                              child: SizedBox(
                                child: widgetPage,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : widgetPage,
            //
            // Left Pane
            //
            isHorizontal
                ? Padding(
                    padding: EdgeInsets.only(
                      top: topPadding,
                      bottom: 100,
                      left: UIConsts.spacing / 2,
                    ),
                    child: Container(
                      width: leftBarWidth,
                      decoration: BoxDecoration(
                          color: gradient
                              ? null
                              : contrastColor.withValues(alpha: .05),
                          gradient: gradient
                              ? LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.2),
                                    accentColor.withValues(alpha: 0)
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  )
                : Container(),
            //
            // Buttons
            //
            isHorizontal
                ? SizedBox(
                    width: leftBarWidth,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: UIConsts.spacing,
                        top: topPadding,
                      ),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: x / 2,
                          ),
                          for (var button in buttons)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: button,
                            )
                        ],
                      ),
                    ),
                  )
                : Positioned(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: buttons,
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
                  ),
            //
            // Player Part
            //
            Positioned(
              bottom: isHorizontal ? 0 : x + iconSize / 2,
              left: isHorizontal ? 0 : x / 4,
              child: const PlayerWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
