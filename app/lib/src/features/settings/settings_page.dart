import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/settings/components/style_button.dart';
import 'package:bossa/src/features/settings/components/theme_slider.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();

    Color? iconColor = themeController.textTheme.headline2!.color;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeController.themeData.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: Icon(
              CupertinoIcons.back,
              size: 30,
              color: iconColor,
            ),
          ),
        ),
        body:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
          const ThemeSlider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Player Style',
                style: themeController.textTheme.headline3!,
              ),
              const SizedBox(
                width: 10,
              ),       
              const StyleButton(style: AudioStyle.classic, label: 'Classic',),       
              const SizedBox(
                width: 10,
              ),
              const StyleButton(style: AudioStyle.modern, label: 'Modern',),    
            ],
          ),
          Text(
            'Ver. 1.0.0 Bossa Music Player',
            style: themeController.textTheme.headline3!,
            textAlign: TextAlign.center,
          )
        ]),
      ),
    );
  }
}
