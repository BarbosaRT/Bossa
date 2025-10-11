import 'dart:async';

import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:bossa/src/url/http_requester.dart';
import 'package:invidious/invidious.dart' as invidious;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeInvidiousParser implements YoutubeParserInterface {
  final invidious.InvidiousClient _invidious;

  YoutubeInvidiousParser({String? serverUrl})
      : _invidious = invidious.InvidiousClient(
            server: serverUrl ?? 'https://inv.nadeko.net');

  @override
  Future<SongModel> convertYoutubeSong(String url) async {
    try {
      final videoId = parseYoutubeSongUrl(url);
      final video = await _invidious.videos.get(videoId);

      return SongModel(
        id: 0,
        title: video.title.replaceAll('"', "'"),
        icon: getYoutubeThumbnail(video.videoThumbnails),
        url: url,
        author: video.author,
      );
    } catch (e) {
      throw Exception('Failed to fetch video: $e');
    }
  }

  @override
  Stream<PlaylistModel> convertYoutubePlaylist(String url) async* {
    try {
      final playlistId = parseYoutubePlaylist(url);
      final playlist = await _invidious.playlist(playlistId);

      print('hi');

      final songs = <SongModel>[];

      for (final video in playlist.videos) {
        try {
          final song = SongModel(
            id: 0,
            title: video.title.replaceAll('"', "'"),
            icon: getYoutubeThumbnail(video.videoThumbnails),
            url: 'https://youtube.com/watch?v=${video.videoId}',
            author: video.author,
          );

          songs.add(song);

          yield PlaylistModel(
            id: 0,
            title: playlist.title,
            icon: songs.isNotEmpty ? songs[0].icon : '',
            songs: List.from(songs),
          );
        } catch (e) {
          // Skip failed video but continue with others
          continue;
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch playlist: $e');
    }
  }

  @override
  String parseYoutubePlaylist(String url) {
    // Extract playlist ID from URL
    final regExp = RegExp(r'[&?]list=([^&]+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return url;
  }

  @override
  String parseYoutubeSongUrl(String url) {
    // Extract video ID from URL
    final regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:watch(?:\?v=|\/))|(?:\?v=|\/))([^#\&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? url;
    }
    return url;
  }

  /// Gets the highest quality audio stream URL for a YouTube video
  /// Similar to YoutubeExplode's withHighestBitrate() functionality
  @override
  Future<String> getHighestQualityAudioUrl(String videoId) async {
    try {
      final video = await _invidious.videos.get(videoId);

      if (video.adaptiveFormats.isEmpty) {
        throw Exception('No adaptive formats available for this video');
      }

      // Filter for audio streams
      final audioFormats = video.adaptiveFormats
          .where((format) => format.type.contains('audio'))
          .toList();

      if (audioFormats.isEmpty) {
        // If no audio streams found, try to use the first available format
        return video.adaptiveFormats.first.url;
      }

      // Find the format with the highest bitrate
      var highestBitrateFormat = audioFormats.reduce((a, b) {
        final aBitrate = _parseBitrate(a.bitrate);
        final bBitrate = _parseBitrate(b.bitrate);
        return aBitrate > bBitrate ? a : b;
      });

      return highestBitrateFormat.url;
    } catch (e) {
      throw Exception('Failed to get audio stream: $e');
    }
  }

  /// Helper method to safely parse bitrate from dynamic value
  int _parseBitrate(dynamic bitrate) {
    if (bitrate == null) return 0;
    if (bitrate is int) return bitrate;
    if (bitrate is double) return bitrate.toInt();
    if (bitrate is String) return int.tryParse(bitrate) ?? 0;
    return 0;
  }

  @override
  String getYoutubeThumbnail(dynamic thumbnails) {
    if (thumbnails is! ThumbnailSet) {
      throw ArgumentError('Thumbnails must be of type ThumbnailSet');
    }

    List<String> thumbnailsList = [
      thumbnails.highResUrl,
      thumbnails.lowResUrl,
      thumbnails.maxResUrl,
      thumbnails.mediumResUrl,
      thumbnails.standardResUrl
    ];

    for (String thumbnail in thumbnailsList) {
      if (thumbnail.isEmpty) continue;
      try {
        HttpRequester().retriveFromUrl(thumbnail);
        return thumbnail;
      } catch (e) {
        continue;
      }
    }
    return 'assets/images/default_album_art.png';
  }
}
