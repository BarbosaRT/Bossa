import 'package:bossa/src/data/youtube/piped_youtube_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Piped API Integration Tests', () {
    test('Test with different instance and known video', () async {
      // Create parser with a known working instance
      final parser =
          PipedYoutubeParser(instanceUrl: 'https://api.piped.private.coffee/');

      // Test with a known YouTube video ID
      const videoId = 'dQw4w9WgXcQ'; // Rick Astley - Never Gonna Give You Up
      const videoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

      // Test URL parsing
      expect(parser.parseYoutubeSongUrl(videoUrl), videoId);

      print(
          'Video ID parsed successfully: ${parser.parseYoutubeSongUrl(videoUrl)}');

      // Test getting audio URL (this might fail depending on API availability)
      try {
        final audioUrl = await parser.getHighestQualityAudioUrl(videoId);
        print(
            'Got audio URL: ${audioUrl.substring(0, audioUrl.length > 50 ? 50 : audioUrl.length)}...');
      } catch (e) {
        print('Failed to get audio URL: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
