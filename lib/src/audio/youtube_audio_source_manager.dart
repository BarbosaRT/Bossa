import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:flutter_modular/flutter_modular.dart';

class YoutubeAudioSourceManager {
  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  late final YoutubeParserInterface _youtubeParser;

  YoutubeAudioSourceManager() {
    // Get the registered YoutubeParserInterface instance from the dependency injection container
    _youtubeParser = Modular.get<YoutubeParserInterface>();
  }

  /// Get audio source from a YouTube URL
  ///
  /// Tries to use the Invidious parser first, falls back to YoutubeExplode if needed
  Future<AudioSource> getAudioSource(String url, {MediaItem? tag}) async {
    try {
      // First try with Invidious parser
      final song = await _youtubeParser.convertYoutubeSong(url);
      if (song.url.isNotEmpty) {
        return LockCachingAudioSource(
          Uri.parse(song.url),
          tag: tag,
        );
      }
    } catch (e) {
      // Fall back to YoutubeExplode if Invidious fails
      return _getAudioSourceWithYoutubeExplode(url, tag: tag);
    }

    // If we get here, fall back to YoutubeExplode
    return _getAudioSourceWithYoutubeExplode(url, tag: tag);
  }

  /// Get audio source using YoutubeExplode as fallback
  Future<AudioSource> _getAudioSourceWithYoutubeExplode(
    String url, {
    MediaItem? tag,
  }) async {
    try {
      final videoId = _youtubeExplode.videos.get(url);
      final streamManifest =
          await _youtubeExplode.videos.streamsClient.getManifest(videoId);
      final streamInfo = streamManifest.audioOnly.withHighestBitrate();

      return LockCachingAudioSource(
        streamInfo.url,
        tag: tag,
      );
    } finally {
      _youtubeExplode.close();
    }
  }

  // Clean up resources
  void dispose() {
    _youtubeExplode.close();
  }
}
