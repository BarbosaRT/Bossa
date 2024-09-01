import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistModel', () {
    test('Test fromMap method', () {
      const id = 1;
      const title = 'My Playlist';
      const icon = 'icon.png';
      final song = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'url1',
        path: 'path1',
      );
      final map = {
        'id': id,
        'title': title,
        'icon': icon,
        'songs': [song.toMap()],
      };
      final PlaylistModel playlist = PlaylistModel.fromMap(map);
      expect(playlist.id, id);
      expect(playlist.title, title);
      expect(playlist.icon, icon);
      expect(playlist.songs.isEmpty, false);
    });

    test('toSql', () {
      final map = {'id': 1, 'title': 'Song 1', 'icon': 'icon1'};
      final song = SongModel(
          id: 1, title: 'title', icon: 'icon', url: 'url', path: 'path');
      final playlist =
          PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: [song]);
      final result = playlist.toSql();
      expect(result['id'] == map['id'], true);
      expect(result['title'] == map['title'], true);
      expect(result['icon'] == map['icon'], true);
      expect(result['songs'], isNull);
    });
  });
}
