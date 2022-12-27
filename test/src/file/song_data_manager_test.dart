import 'package:bossa/src/file/song_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/models/song_model.dart';

void main() {
  group('SongDataManager', () {
    final filePath = FilePathImpl();
    final songDataManager = SongDataManager(filePath: filePath);
    final song1 = SongModel(
        id: 2, title: 'Song 1', icon: 'icon1', url: 'url1', path: 'path1');

    songDataManager.init();

    test('test if adds song', () {
      songDataManager.addSong(song1);
    });

    test('test if loadSong loads songs', () async {
      //Only works if you specify the right id at the top
      songDataManager.addSong(song1);
      final SongModel? loadedSong1 = await songDataManager.loadSong(song1.id);
      expect(loadedSong1, isNotNull);
      expect(loadedSong1?.url, song1.url);
    });

    test('test if loadSong returns null when id is invalid', () async {
      songDataManager.addSong(song1);
      final SongModel? loadedSong1 = await songDataManager.loadSong(-1);
      expect(loadedSong1, null);
    });

    test('removeSong', () {
      songDataManager.removeSong(song1);
    });
  });
}
