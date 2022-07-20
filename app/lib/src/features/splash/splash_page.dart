import 'package:bossa/src/features/splash/splash_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>{  
  @override
  void initState() {
    var splashNotifier = context.read<SplashNotifier>();
    splashNotifier.addListener(() {
      if (splashNotifier.splashState == SplashState.finished){
        Navigator.of(context).pushReplacementNamed('/');
      }
     });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: themeController.themeData.backgroundColor,
    );
  }
}
