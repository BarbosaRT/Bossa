import 'dart:io';
import 'package:asuka/asuka.dart';
import 'package:bossa/src/color/app_colors.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<bool> saveDatabase() async {
    await FilePicker.platform.clearTemporaryFiles();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.path!.endsWith('.db')) {
        String databasePath = await dataManagerInstance.getDatabasePath();
        await File(file.path!).copy(databasePath);
        dataManagerInstance.reloadDatabase();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settingsController = Modular.get<SettingsController>();
    final downloadService = Modular.get<HttpDownloadService>();

    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final contrastColor = colorController.currentTheme.contrastColor;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);

    final settingStyle = TextStyles().headline2.copyWith(color: contrastColor);
    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );

    return SafeArea(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ListView(
          children: [
            SizedBox(
              height: x / 2,
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('config'.i18n(), style: headerStyle),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('use-gradient'.i18n(), style: settingStyle),
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
                ),
                SizedBox(
                  width: x / 2,
                ),
              ],
            ),
            //
            // Accent Color
            //
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('main-color'.i18n(), style: settingStyle),
                const Spacer(),
                for (Color color in AccentColors().listOfColors)
                  Radio<Color>(
                    fillColor: WidgetStateProperty.all(color),
                    value: color,
                    groupValue: colorController.currentAccent,
                    onChanged: (newColor) async {
                      if (newColor == null) {
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();
                      // ignore: deprecated_member_use
                      prefs.setInt('accentColor', newColor.value);
                      colorController.changeAccentColor(newColor);
                    },
                  ),
                SizedBox(
                  width: x / 2,
                ),
              ],
            ),
            //
            // Change Theme
            //
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('change-theme'.i18n(), style: settingStyle),
                const Spacer(),
                DropdownButton<AppColors>(
                  dropdownColor: backgroundColor,
                  items: [
                    DropdownMenuItem<DarkTheme>(
                      value: DarkTheme(),
                      child: Text('dark-theme'.i18n(), style: settingStyle),
                    ),
                    DropdownMenuItem<LightTheme>(
                      value: LightTheme(),
                      child: Text('light-theme'.i18n(), style: settingStyle),
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
                SizedBox(
                  width: x / 2,
                ),
              ],
            ),
            //
            // Updates
            //
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('verify-update'.i18n(), style: settingStyle),
                const Spacer(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(backgroundAccent)),
                  onPressed: () async {
                    bool hasUpdate = await settingsController.hasUpdate();
                    if (hasUpdate) {
                      Asuka.showSnackBar(
                        SnackBar(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          duration: const Duration(days: 1),
                          content: Container(
                            height: 100,
                            width: size.width,
                            decoration: BoxDecoration(
                              color: backgroundAccent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      'https://github.com/BarbosaRT/Bossa/releases',
                                    ),
                                  );
                                },
                                style: buttonStyle,
                                child: Text(
                                  'update-found'.i18n(),
                                  style: settingStyle.copyWith(
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      Asuka.showSnackBar(
                        SnackBar(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          duration: const Duration(days: 1),
                          content: Container(
                            height: 50,
                            width: size.width,
                            decoration: BoxDecoration(
                              color: backgroundAccent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'update-not-found'.i18n(),
                                style: settingStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'verify'.i18n(),
                    style: settingStyle,
                  ),
                ),
                SizedBox(
                  width: x / 2,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: x / 2,
                ),
                Text('Backups', style: settingStyle),
                const Spacer(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(backgroundAccent)),
                  onPressed: () async {
                    if (await saveDatabase()) {
                      Asuka.showSnackBar(
                        SnackBar(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          content: Container(
                            height: 70,
                            width: size.width,
                            decoration: BoxDecoration(
                              color: backgroundAccent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'backup-loaded'.i18n(),
                                style: settingStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      Asuka.showSnackBar(
                        SnackBar(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          content: Container(
                            height: 50,
                            width: size.width,
                            decoration: BoxDecoration(
                              color: backgroundAccent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'error'.i18n(),
                                style: settingStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'import'.i18n(),
                    style: settingStyle,
                  ),
                ),
                SizedBox(
                  width: x / 4,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(backgroundAccent)),
                  onPressed: () async {
                    final databasePath =
                        await dataManagerInstance.getDatabasePath();
                    String externalDirectory = '';
                    if (Platform.isAndroid) {
                      bool hasPermission =
                          await downloadService.requestWritePermission();
                      if (!hasPermission) throw Exception('Permission Denied');
                      externalDirectory =
                          await FilePathImpl().getExternalDirectory();
                    } else if (!Platform.isIOS) {
                      String? outputFile = await FilePicker.platform.saveFile(
                        dialogTitle: '${"select-dir".i18n()}:',
                        fileName: dataManagerInstance.databaseName,
                      );

                      if (outputFile != null) {
                        externalDirectory = outputFile;
                      }
                    }
                    await Directory(externalDirectory).create();
                    File(databasePath).copy(
                        '$externalDirectory/${dataManagerInstance.databaseName}');
                    Asuka.showSnackBar(
                      SnackBar(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        content: Container(
                          height: 80,
                          width: size.width,
                          decoration: BoxDecoration(
                            color: backgroundAccent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              '${"backup-saved".i18n()}: $externalDirectory/${dataManagerInstance.databaseName}',
                              style: settingStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'export'.i18n(),
                    style: settingStyle,
                  ),
                ),
                SizedBox(
                  width: x / 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
