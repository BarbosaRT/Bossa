import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bossa/src/main_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Configure media_kit to avoid XCB issues
  JustAudioMediaKit.ensureInitialized();

  JustAudioMediaKit.title = 'Bossa';
  JustAudioMediaKit.protocolWhitelist = ['file', 'http', 'https'];
  JustAudioMediaKit.bufferSize = 128 * 1024 * 1024;

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));

  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Bossa";
    appWindow.show();
  });
}
