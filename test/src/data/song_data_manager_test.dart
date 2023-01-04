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
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path1');
    final song2 = SongModel(
        id: 2,
        title: 'Song 2',
        icon: 'icon2',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path3');

    test('test if adds song', () {
      songDataManager.addSong(song1);
    });

    test('test if adds multiple songs', () async {
      songDataManager.deleteAll();
      songDataManager.addSong(song1);
      songDataManager.addSong(song2);
      final List<SongModel> loadedSong1 = await songDataManager.loadAllSongs();
      expect(loadedSong1, isNotNull);
      expect(loadedSong1.length, 2);
    });

    test('test if loadSongs loads songs', () async {
      songDataManager.deleteAll();
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

    test('removeSong', () async {
      songDataManager.deleteAll();

      songDataManager.addSong(song1);
      final List<SongModel> loadedSongs1 = await songDataManager.loadAllSongs();

      songDataManager.removeSong(song1);
      final List<SongModel> loadedSongs2 = await songDataManager.loadAllSongs();

      expect(loadedSongs1.length - 1, loadedSongs2.length);
    });

    test('editSong', () async {
      final song2 = SongModel(
          id: 2,
          title: 'Song 1',
          icon: 'icon1',
          url: 'https://youtu.be/NgYoUsdETRw',
          path: 'path1');
      songDataManager.deleteAll();

      songDataManager.addSong(song2);
      song2.title = 'EditedSong';
      songDataManager.editSong(song2);
      final List<SongModel> loadedSongs2 = await songDataManager.loadAllSongs();

      expect(loadedSongs2[0].title == 'EditedSong', true);
    });
  });
}
