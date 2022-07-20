import 'package:bossa/src/features/files/file_controller.dart';
import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final fileController = context.watch<FileNotifier>();
    final themeController = context.watch<ThemeNotifier>();
    
    TextStyle? headline2 = themeController.textTheme.headline2;
    TextStyle? headline4 = themeController.textTheme.headline4;
    Color backgroundColor = themeController.themeData.backgroundColor;
    Color widgetColor = themeController.themeData.cardColor;
    Color primaryColor = Colors.blue;
    
    return Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Text(
                'Upload your file',
                style: headline2,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: fileController.audioSave,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 20.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: const [10, 10],
                      strokeCap: StrokeCap.round,
                      color: primaryColor,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                            color: widgetColor
                                .withOpacity(.7),
                            borderRadius:
                                BorderRadius.circular(
                                    10)),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_open,
                              color: primaryColor,
                              size: 40,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Select your file',
                              style: headline4,
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              Text(
                fileController.songModel.audio,
                style: headline4,
              ),
            ],
          ),
        ),
      );
  }
}