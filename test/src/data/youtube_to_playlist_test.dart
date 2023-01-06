import 'dart:io';

import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/youtube_to_playlist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('youtubeToPlaylist', () {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    test('Test convertYoutubePlaylist() method', () async {
      YoutubeToPlaylist converter = YoutubeToPlaylist();
      PlaylistModel playlist = await converter.convertYoutubePlaylist(
          'https://www.youtube.com/playlist?list=PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI');
      expect(playlist.songs.length, 200);
    });
  });
}
