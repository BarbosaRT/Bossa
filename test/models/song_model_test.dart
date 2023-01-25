import 'package:bossa/models/song_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongModel', () {
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

    test('toMap', () {
      final map = {
        'id': 1,
        'title': 'Song 1',
        'icon': 'icon1',
        'url': 'url1',
        'path': 'path1',
      };
      final song = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'url1',
        path: 'path1',
      );
      final result = song.toMap();      
      expect(result['id'] == map['id'], true);
      expect(result['title'] == map['title'], true);
      expect(result['icon'] == map['icon'], true);
      expect(result['url'] == map['url'], true);
      expect(result['path'] == map['path'], true);
    });
  });
}
