import 'dart:io';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('youtubeToPlaylist', () {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    test('Test convertYoutubePlaylist() method', () async {
      YoutubeParser converter = YoutubeParser(
          songDataManager: SongDataManager(
              localDataManagerInstance: testDataManagerInstance,
              downloadService: HttpDownloadService(filePath: FilePathImpl())));
      Stream<PlaylistModel> playlistStream = converter.convertYoutubePlaylist(
          'https://www.youtube.com/playlist?list=PLXUeUBhvfMh8ivldygLkBMnXhSCH84nEu');
      List<SongModel> songs = [];
      await for (var playlist in playlistStream) {
        songs = playlist.songs;
      }
      expect(songs.length, 13);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
