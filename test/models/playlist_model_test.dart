import 'package:bossa/models/playlist_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistModel', () {
    test('Test fromMap method', () {
      const id = 1;
      const title = 'My Playlist';
      const icon = 'icon.png';
      final map = {
        'id': id,
        'title': title,
        'icon': icon,
      };
      final playlist = PlaylistModel.fromMap(map);
      expect(playlist.id, id);
      expect(playlist.title, title);
      expect(playlist.icon, icon);
    });
  });
}
