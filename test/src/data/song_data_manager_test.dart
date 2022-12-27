import 'package:bossa/src/data/song_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/models/song_model.dart';

void main() {
  group('SongDataManager', () {
    final songDataManager = SongDataManager();
    final song1 = SongModel(
        id: 2,
        title: 'Song 1',
        icon: 'icon1',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path1');

    songDataManager.init();

    test('test if adds song', () {
      songDataManager.addSong(song1);
    });

    test('test if loadSongs loads songs', () async {
      songDataManager.addSong(song1);
      final List<SongModel> loadedSong1 = await songDataManager.loadSongs();
      expect(loadedSong1, isNotNull);
      expect(loadedSong1.isEmpty, false);
    });

    test('test if loadSong returns null when id is invalid', () async {
      songDataManager.deleteAll();
      songDataManager.init();
      final List<SongModel> loadedSong1 = await songDataManager.loadSongs();
      expect(loadedSong1, []);
    });

    test('removeSong', () {
      songDataManager.removeSong(song1);
    });
  });
}
