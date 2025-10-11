import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';

abstract class YoutubeParserInterface {
  Future<SongModel> convertYoutubeSong(String url);
  Stream<PlaylistModel> convertYoutubePlaylist(String url);
  String parseYoutubePlaylist(String url);
  String getYoutubeThumbnail(dynamic thumbnails);
  String parseYoutubeSongUrl(String url);
  
  /// Gets the highest quality audio stream URL for a YouTube video
  /// Similar to YoutubeExplode's withHighestBitrate() functionality
  Future<String> getHighestQualityAudioUrl(String videoId);
}
