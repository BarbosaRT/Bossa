import 'package:bossa/app/controllers/app_controller.dart';
import 'package:bossa/app/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final AppControllerState appController;
  const SettingsPage({Key? key, required this.appController}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool switch_value = true;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).backgroundColor;
    Color widgetColor = Theme.of(context).cardColor;

    TextStyle headline3 = Theme.of(context).textTheme.headline3!;
    TextStyle headline2 = Theme.of(context).textTheme.headline2!;
    TextStyle headline4 = Theme.of(context).textTheme.headline4!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
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
              color: headline2.color,
            ),
          ),
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Switch Theme',
                style: headline3,
              ),
              Switch(
                  value: switch_value,
                  onChanged: (value) {
                    setState(() {
                      switch_value = value;
                    });
                    widget.appController.changeTheme();
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Player Style',
                style: headline3,
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(widgetColor)),
                  onPressed: () {
                    widget.appController.homeStyle(SelectedScreen.style1);
                  },
                  child: Text('1', style: headline3)),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(widgetColor)),
                  onPressed: () {
                    widget.appController.homeStyle(SelectedScreen.style2);
                  },
                  child: Text('2', style: headline3))
            ],
          ),
          Text(
            'Ver. 1.0.0 Bossa Music Player',
            style: headline2,
          )
        ]),
      ),
    );
  }
}
