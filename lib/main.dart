import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bossa/src/main_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  if (Platform.isLinux) {
    DartVLC.initialize();
  }

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
