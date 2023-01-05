import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/youtube_to_playlist.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('youtubeToPlaylist', () {
    test('Test convertYoutubePlaylist() method', () async {
      YoutubeToPlaylist converter = YoutubeToPlaylist();
      PlaylistModel playlist = await converter.convertYoutubePlaylist(
          'https://www.youtube.com/playlist?list=PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI');
      expect(playlist.songs.length, 200);
    });
  });
}
