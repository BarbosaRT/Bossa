import 'package:bossa/src/data/youtube/piped_youtube_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PipedYoutubeParser parser;

  setUp(() {
    parser = PipedYoutubeParser();
  });

  group('parseYoutubeSongUrl', () {
    test('should extract video ID from standard YouTube URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final result = parser.parseYoutubeSongUrl(url);
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should extract video ID from youtu.be URL', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      final result = parser.parseYoutubeSongUrl(url);
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should extract video ID from embedded YouTube URL', () {
      const url = 'https://www.youtube.com/embed/dQw4w9WgXcQ';
      final result = parser.parseYoutubeSongUrl(url);
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should extract video ID from YouTube shorts URL', () {
      const url = 'https://www.youtube.com/shorts/dQw4w9WgXcQ';
      final result = parser.parseYoutubeSongUrl(url);
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should return original URL if no video ID found', () {
      const url = 'https://www.example.com';
      final result = parser.parseYoutubeSongUrl(url);
      expect(result, url);
    });
  });

  group('parseYoutubePlaylist', () {
    test('should extract playlist ID from YouTube URL', () {
      const url = 'https://www.youtube.com/playlist?list=PLABC123';
      final result = parser.parseYoutubePlaylist(url);
      expect(result, 'PLABC123');
    });

    test('should extract playlist ID from URL with additional parameters', () {
      const url = 'https://www.youtube.com/playlist?list=PLABC123&t=10s';
      final result = parser.parseYoutubePlaylist(url);
      expect(result, 'PLABC123');
    });

    test('should return original URL if no playlist ID found', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final result = parser.parseYoutubePlaylist(url);
      expect(result, url);
    });
  });

  group('convertYoutubeSong', () {
    test('should convert YouTube video to SongModel', () async {
      // Test with a known YouTube video URL
      const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

      final song = await parser.convertYoutubeSong(testUrl);

      expect(song, isNotNull);
      expect(song.url, testUrl);
      expect(song.title, isNotEmpty);
      expect(song.author, isNotEmpty);
      expect(song.icon, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('should throw for invalid video URL', () async {
      const invalidUrl = 'https://www.youtube.com/watch?v=invalid123';

      expect(
        () => parser.convertYoutubeSong(invalidUrl),
        throwsA(isA<Exception>()),
      );
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('getHighestQualityAudioUrl', () {
    test('should get highest quality audio URL for a valid video ID', () async {
      const videoId = 'dQw4w9WgXcQ';

      final audioUrl = await parser.getHighestQualityAudioUrl(videoId);

      expect(audioUrl, isNotNull);
      expect(audioUrl, contains('http'));
      expect(audioUrl, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('should throw for invalid video ID', () async {
      const invalidVideoId = 'invalid123';

      expect(
        () => parser.getHighestQualityAudioUrl(invalidVideoId),
        throwsA(isA<Exception>()),
      );
    }, timeout: const Timeout(Duration(seconds: 15)));
  });

  group('getYoutubeThumbnail', () {
    test('should return valid thumbnail URL when given a valid URL string', () {
      const thumbnailUrl = 'https://example.com/thumbnail.jpg';

      final result = parser.getYoutubeThumbnail(thumbnailUrl);

      expect(result, thumbnailUrl);
    });

    test('should return default thumbnail when given an invalid URL', () {
      const invalidUrl = 'not_a_valid_url';

      final result = parser.getYoutubeThumbnail(invalidUrl);

      expect(result, 'assets/images/default_album_art.png');
    });

    test('should return default thumbnail when given null', () {
      final result = parser.getYoutubeThumbnail(null);

      expect(result, 'assets/images/default_album_art.png');
    });
  });

  group('convertYoutubePlaylist', () {
    test('should throw exception for playlist functionality not supported', () async {
      const playlistUrl = 'https://www.youtube.com/playlist?list=PLABC123';

      await expectLater(
        () => parser.convertYoutubePlaylist(playlistUrl).toList(),
        throwsA(isA<Exception>()),
      );
    });
  });
}