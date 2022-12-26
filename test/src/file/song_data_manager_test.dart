import 'package:bossa/src/file/song_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/models/song_model.dart';

void main() {
  group('SongDataManager', () {
    final filePath = FilePathImpl();
    final songDataManager = SongDataManager(filePath: filePath);
    final song1 = SongModel(
        id: 1, title: 'Song 1', icon: 'icon1', url: 'url1', path: 'path1');
    final song2 = SongModel(
        id: 2, title: 'Song 2', icon: 'icon2', url: 'url2', path: 'path2');

    songDataManager.init();

    test('addSong', () {
      songDataManager.addSong(song1);
      songDataManager.addSong(song2);
    });

    test('loadSong', () async {
      final loadedSong1 = await songDataManager.loadSong(1);
      expect(loadedSong1, equals(song1));

      final loadedSong2 = await songDataManager.loadSong(2);
      expect(loadedSong2, equals(song2));
    });

    test('removeSong', () {
      songDataManager.removeSong(song1);
      songDataManager.removeSong(song2);
    });
  });
}
