import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('songUrlParser', () {
    SongUrlParser songUrlParser = SongUrlParser();
    SongModel song = SongModel(
        id: 0, title: 'title', icon: 'icon', url: 'NgYoUsdETRw', path: 'path');

    test('Test if it can parse the songs to play', () async {
      String result = await songUrlParser.parseSongUrlToPlay(song.url);
      expect(result, 'https://yewtu.be/embed/NgYoUsdETRw?raw=1');
    });

    test('Test if it can parse the songs to save', () async {
      String url = 'https://youtu.be/dQw4w9WgXcQ';
      String result = songUrlParser.parseSongUrlToSave(url);
      expect(result, 'dQw4w9WgXcQ');
    });
  });
}
