import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:piped_client/piped_client.dart';

class PipedYoutubeParser implements YoutubeParserInterface {
  final PipedClient _pipedClient;

  PipedYoutubeParser({String? instanceUrl})
      //: _pipedClient = PipedClient(instance: instanceUrl ?? 'https://pipedapi.kavin.rocks');
      : _pipedClient = PipedClient(
            instance: instanceUrl ?? 'https://api.piped.private.coffee/');

  @override
  Future<SongModel> convertYoutubeSong(String url) async {
    try {
      // Extract video ID from the URL
      final videoId = parseYoutubeSongUrl(url);

      // Get stream information from Piped API
      final streamInfo = await _pipedClient.streams(videoId);

      return SongModel(
        id: 0,
        title: (streamInfo.title as String?)?.replaceAll('"', "'") ?? '',
        icon: getYoutubeThumbnail(streamInfo.thumbnailUrl),
        url: url,
        author: streamInfo.uploader as String? ?? '',
      );
    } catch (e) {
      throw Exception('Failed to fetch video: $e');
    }
  }

  @override
  Stream<PlaylistModel> convertYoutubePlaylist(String url) async* {
    try {
      // Extract playlist ID from URL
      parseYoutubePlaylist(url);

      // Piped API doesn't currently have direct playlist conversion in piped_client
      // For now, we'll throw an exception indicating this functionality is not supported
      throw Exception(
          'Playlist functionality not supported by piped_client yet');
    } catch (e) {
      throw Exception('Failed to fetch playlist: $e');
    }
  }

  @override
  String parseYoutubePlaylist(String url) {
    // Extract playlist ID from URL using regex
    final regExp = RegExp(r'[&?]list=([^&]+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? url;
    }
    return url;
  }

  @override
  String parseYoutubeSongUrl(String url) {
    // Extract video ID from various YouTube URL formats using the same regex as the existing parsers
    final regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:watch(?:\?v=|\/))|(?:\?v=|\/))([^#&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final videoId = match.group(1);
      // Only return the videoId if it looks like a valid YouTube video ID (11 characters, alphanumerical)
      if (videoId != null &&
          RegExp(r'^[a-zA-Z0-9_-]{10,12}$').hasMatch(videoId)) {
        return videoId;
      }
    }
    return url;
  }

  @override
  Future<String> getHighestQualityAudioUrl(String videoId) async {
    try {
      // Get stream information from Piped API
      final streamInfo = await _pipedClient.streams(videoId);

      // Look for audio streams and find the highest quality one
      if (streamInfo.audioStreams.isNotEmpty) {
        // Find the audio stream with the highest quality (assuming it's a string like "128kbps")
        var highestQualityStream = streamInfo.audioStreams.first;
        for (var stream in streamInfo.audioStreams) {
          if (_compareQuality(stream.quality, highestQualityStream.quality) >
              0) {
            highestQualityStream = stream;
          }
        }

        return highestQualityStream.url as String? ?? '';
      }

      //If no audio streams are available, return the first video stream as fallback
      if (streamInfo.videoStreams.isNotEmpty) {
        return streamInfo.videoStreams.first.url as String? ?? '';
      }
      throw Exception('No audio streams available for this video');
    } catch (e) {
      throw Exception('Failed to get audio stream: $e');
    }
  }

  @override
  String getYoutubeThumbnail(dynamic thumbnails) {
    // Handle the thumbnail URL from Piped API
    if (thumbnails is String && thumbnails.isNotEmpty) {
      // Direct URL string - check if it's a valid URL
      try {
        final uri = Uri.parse(thumbnails);
        if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
          return thumbnails;
        }
      } catch (e) {
        // Continue to default if URL is invalid
      }
    }

    return 'assets/images/default_album_art.png';
  }

  /// Helper method to compare quality strings like '128kbps', 'highest', etc.
  int _compareQuality(dynamic quality1, dynamic quality2) {
    if (quality1 == null && quality2 == null) return 0;
    if (quality1 == null) return -1;
    if (quality2 == null) return 1;

    String q1 = quality1.toString().toLowerCase();
    String q2 = quality2.toString().toLowerCase();

    // If both are not numeric, just compare as strings
    // If we have something like 'highest', 'lowest', use special handling
    if (q1.contains('highest')) return 1;
    if (q2.contains('highest')) return -1;
    if (q1.contains('lowest')) return -1;
    if (q2.contains('lowest')) return 1;

    // Extract numeric value from quality string (e.g., '128kbps' -> 128)
    RegExp numberRegex = RegExp(r'\d+');
    Match? match1 = numberRegex.firstMatch(q1);
    Match? match2 = numberRegex.firstMatch(q2);

    if (match1 != null && match2 != null) {
      int num1 = int.parse(match1.group(0)!);
      int num2 = int.parse(match2.group(0)!);
      return num1.compareTo(num2);
    }

    // If we can't parse numbers, compare as strings
    return q1.compareTo(q2);
  }
}
