import 'package:bossa/src/url/crawler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Crawler', () {
    Crawler crawler = Crawler();

    test('getWebsiteData', () async {
      await crawler.getWebsiteData(
          'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ');
    });
  });
}
