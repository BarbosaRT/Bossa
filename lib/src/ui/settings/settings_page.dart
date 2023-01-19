import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static double x = 30;
  bool gradient = false;

  @override
  void initState() {
    super.initState();
    final settingsController = Modular.get<SettingsController>();
    gradient = settingsController.gradientOnPlayer;
    settingsController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          gradient = settingsController.gradientOnPlayer;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final settingsController = Modular.get<SettingsController>();

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);

    final settingStyle = TextStyles().headline2.copyWith(color: contrastColor);

    return SafeArea(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SizedBox(
              height: x / 2,
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('Configurações', style: headerStyle),
              ],
            ),
            SizedBox(
              height: x / 4,
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('Gradiente no player', style: settingStyle),
                const Spacer(),
                Switch(
                  value: gradient,
                  onChanged: (value) {
                    settingsController.setGradientOnPlayer(value);
                    setState(() {
                      gradient = value;
                    });
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
