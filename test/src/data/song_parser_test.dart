import 'package:bossa/src/data/song_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('songUrlParser', () {
    SongParser songUrlParser = SongParser();
    test('Test if it can parse the songs to save', () async {
      String url = 'https://youtu.be/dQw4w9WgXcQ';
      String result = songUrlParser.parseYoutubeSongUrl(url);
      expect(result, 'dQw4w9WgXcQ');
    });
  });
}
