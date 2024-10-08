import 'dart:io';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/models/song_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('DataManager', () {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final playlistDataManager =
        PlaylistDataManager(localDataManagerInstance: testDataManagerInstance);
    final songDataManager = SongDataManager(
        localDataManagerInstance: testDataManagerInstance,
        downloadService: HttpDownloadService(filePath: FilePathImpl()));
    final playlist =
        PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);
    final song = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path1');

    test('test if creates the tables', () async {
      var database = await testDataManagerInstance.database();
      testDataManagerInstance.createTables(database);

      // Only works if the tables exists
      songDataManager.addSong(song);
      playlistDataManager.addPlaylist(playlist);
      playlistDataManager.appendToPlaylist(song, playlist);
    });
  });
}
