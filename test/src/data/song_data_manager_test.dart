import 'dart:io';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/models/song_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SongDataManager', () {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final songDataManager = SongDataManager();
    final song1 = SongModel(
        id: 2,
        title: 'Song 1',
        icon: 'icon1',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path1');

    test('test if adds song', () {
      songDataManager.addSong(song1);
    });

    test('test if loadSongs loads songs', () async {
      songDataManager.addSong(song1);
      final List<SongModel> loadedSong1 = await songDataManager.loadAllSongs();
      expect(loadedSong1, isNotNull);
      expect(loadedSong1.isEmpty, false);
    });

    test('test if loadSong returns a empty list when list is empty', () async {
      songDataManager.deleteAll();
      final List<SongModel> loadedSong1 = await songDataManager.loadAllSongs();
      expect(loadedSong1, []);
    });

    test('removeSong', () {
      songDataManager.removeSong(song1);
    });
  });
}
