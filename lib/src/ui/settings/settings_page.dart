import 'package:bossa/src/color/app_colors.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static double x = UIConsts.spacing;
  bool gradient = false;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    final settingsController = Modular.get<SettingsController>();
    gradient = settingsController.gradient;
    settingsController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            gradient = settingsController.gradient;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settingsController = Modular.get<SettingsController>();

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final contrastColor = colorController.currentTheme.contrastColor;

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
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('Usar gradiente', style: settingStyle),
                const Spacer(),
                Switch(
                  value: gradient,
                  onChanged: (value) async {
                    settingsController.setGradientOnPlayer(value);

                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('gradientOnPlayer', value);
                    setState(() {
                      gradient = value;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: x / 2,
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('Cor principal', style: settingStyle),
                const Spacer(),
                for (Color color in AccentColors().listOfColors)
                  Radio<Color>(
                    fillColor: MaterialStateProperty.all(color),
                    value: color,
                    groupValue: colorController.currentAccent,
                    onChanged: (newColor) async {
                      if (newColor == null) {
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setInt('accentColor', newColor.value);
                      colorController.changeAccentColor(newColor);
                    },
                  ),
              ],
            ),
            Row(children: [
              SizedBox(
                width: x / 2,
              ),
              Text('Mudar tema', style: settingStyle),
              const Spacer(),
              DropdownButton<AppColors>(
                dropdownColor: backgroundColor,
                items: [
                  DropdownMenuItem<DarkTheme>(
                    value: DarkTheme(),
                    child: Text('Tema Escuro', style: settingStyle),
                  ),
                  DropdownMenuItem<LightTheme>(
                    value: LightTheme(),
                    child: Text('Tema Claro', style: settingStyle),
                  ),
                ],
                onChanged: (v) async {
                  if (v == null) {
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('currentTheme', Themes().indexOf(v));
                  colorController.changeTheme(v);
                },
              ),
            ])
          ],
        ),
      ),
    );
  }
}
