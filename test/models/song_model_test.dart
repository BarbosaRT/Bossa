import 'package:bossa/models/song_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongModel', () {
    test('toSQL', () {
      final song = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'url1',
        path: 'path1',
      );
      const expectedSQL = "('Song 1', 'icon1', 'url1', 'path1')";
      expect(song.toSQL(), equals(expectedSQL));
    });

    test('fromMap', () {
      final map = {
        'id': 1,
        'title': 'Song 1',
        'icon': 'icon1',
        'url': 'url1',
        'path': 'path1',
      };
      final expectedSong = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'url1',
        path: 'path1',
      );
      expect(SongModel.fromMap(map) == expectedSong, true);
    });
  });
}
