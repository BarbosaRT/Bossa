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
        ChildRoute(
          '/songAddPage',
          child: (context, args) => const SongAddPage(),
          duration: const Duration(seconds: 3),
          transition: TransitionType.custom,
          customTransition: CustomTransition(
            opaque: false,
            transitionBuilder: (context, anim1, anim2, child) {
              const Offset begin = Offset(0, 1);
              const Offset end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = anim1.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        ),
      ];
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wave',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
            trackVisibility:
                MaterialStateProperty.resolveWith((states) => true)),
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
