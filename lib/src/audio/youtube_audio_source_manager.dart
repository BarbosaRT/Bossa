import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:flutter_modular/flutter_modular.dart';

class YoutubeAudioSourceManager {
  static const _youtubeHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
  };

  late final YoutubeParserInterface _youtubeParser;

  YoutubeAudioSourceManager() {
    _youtubeParser = Modular.get<YoutubeParserInterface>();
  }

  Future<AudioSource> getAudioSource(String url, {MediaItem? tag}) async {
    final videoId = _youtubeParser.parseYoutubeSongUrl(url);
    final audioUri = await _youtubeParser.getHighestQualityAudioUrl(videoId);
    return AudioSource.uri(audioUri, headers: _youtubeHeaders, tag: tag);
  }
}
