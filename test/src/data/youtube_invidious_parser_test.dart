import 'package:bossa/src/data/youtube/youtube_invidious_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late YoutubeInvidiousParser parser;

  setUp(() {
    parser = YoutubeInvidiousParser();
    // You can override the private _invidious client for testing if needed
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
  });

  group('parseYoutubePlaylist', () {
    test('should extract playlist ID from YouTube URL', () {
      const url = 'https://www.youtube.com/playlist?list=PLABC123';
      final result = parser.parseYoutubePlaylist(url);
      expect(result, 'PLABC123');
    });

    test('should throw for invalid playlist URL', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(() => parser.parseYoutubePlaylist(url), throwsException);
    });
  });

  group('convertYoutubeSong', () {
    test('should convert YouTube video to SongModel', () async {
      final parser = YoutubeInvidiousParser();
      // Test with a known YouTube video URL
      const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

      final song = await parser.convertYoutubeSong(testUrl);

      expect(song, isNotNull);
      expect(song.url, testUrl);
      print(song.title);
      expect(song.title, isNotEmpty);
      expect(song.author, isNotEmpty);
      expect(song.icon, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('should throw for invalid video URL', () async {
      final parser = YoutubeInvidiousParser();
      const invalidUrl = 'https://www.youtube.com/watch?v=invalid123';

      expect(
        () => parser.convertYoutubeSong(invalidUrl),
        throwsA(isA<Exception>()),
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('convertYoutubePlaylist', () {
    test('should stream playlist conversion progress', () async {
      final parser = YoutubeInvidiousParser();
      // Test with a known public playlist
      const playlistUrl =
          'https://www.youtube.com/playlist?list=PLXUeUBhvfMh8ivldygLkBMnXhSCH84nEu';

      final stream = parser.convertYoutubePlaylist(playlistUrl);

      // Collect all playlist updates
      final playlists = await stream.toList();

      // Should have at least one playlist update
      expect(playlists, isNotEmpty);

      final finalPlaylist = playlists.last;

      // Basic validation of the final playlist
      expect(finalPlaylist.title, isNotEmpty);
      expect(finalPlaylist.songs, isNotEmpty);

      // Verify first song
      final firstSong = finalPlaylist.songs.first;
      expect(firstSong.title, isNotEmpty);
      expect(firstSong.url, contains('youtube.com/watch?v='));
      expect(firstSong.author, isNotEmpty);
      expect(firstSong.icon, isNotEmpty);

      // Verify progress updates (should have one update per song)
      for (var i = 0; i < playlists.length; i++) {
        expect(playlists[i].songs.length, i + 1);
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('should handle empty playlists', () async {
      final parser = YoutubeInvidiousParser();
      // This should be a valid playlist ID format but non-existent
      const emptyPlaylistUrl =
          'https://www.youtube.com/playlist?list=PL00000000000000000000000000000000';

      final stream = parser.convertYoutubePlaylist(emptyPlaylistUrl);

      // Should complete with an empty list or throw an exception
      await expectLater(
        stream.toList(),
        throwsA(isA<Exception>()),
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
