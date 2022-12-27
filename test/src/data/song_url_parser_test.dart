import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('songUrlParser', () {
    SongUrlParser songUrlParser = SongUrlParser();
    SongModel song = SongModel(
        id: 0, title: 'title', icon: 'icon', url: 'NgYoUsdETRw', path: 'path');

    test('Test if it can parse the songs to an invidious instance', () async {
      String result = await songUrlParser.parseSongUrlToInvidious(song.url);
      expect(result, 'https://yewtu.be/watch?v=NgYoUsdETRw');
    });
  });
}
