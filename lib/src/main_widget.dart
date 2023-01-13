import 'package:asuka/asuka.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/ui/file/song_add_page.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind((i) => ColorController()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (context, args) => const HomePage(),
        ),
      ];
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Modular.setObservers([Asuka.asukaHeroController]);

    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentScheme.accentColor;

    Map<int, Color> color = {
      50: accentColor.withOpacity(.1),
      100: accentColor.withOpacity(.2),
      200: accentColor.withOpacity(.3),
      300: accentColor.withOpacity(.4),
      400: accentColor.withOpacity(.5),
      500: accentColor.withOpacity(.6),
      600: accentColor.withOpacity(.7),
      700: accentColor.withOpacity(.8),
      800: accentColor.withOpacity(.9),
      900: accentColor.withOpacity(1),
    };
    MaterialColor colorCustom = MaterialColor(0xFF002277, color);

    return MaterialApp.router(
      builder: Asuka.builder,
      debugShowCheckedModeBanner: false,
      title: 'Wave',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
            trackVisibility:
                MaterialStateProperty.resolveWith((states) => true)),
        primarySwatch: colorCustom,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
