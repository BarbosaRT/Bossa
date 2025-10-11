import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:bossa/src/url/http_requester.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeExplodeParser implements YoutubeParserInterface {
  final SongDataManager? songDataManager;
  final DataManager dataManager;
  final FilePath filePath;
  final HttpDownloadService downloadService;

  YoutubeExplodeParser({
    this.songDataManager,
    DataManager? dataManager,
    FilePath? filePath,
    HttpDownloadService? downloadService,
  })  : dataManager = dataManager ?? Modular.get<DataManager>(),
        filePath = filePath ?? FilePathImpl(),
        downloadService = downloadService ??
            HttpDownloadService(filePath: filePath ?? FilePathImpl());

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

  @override
  Future<SongModel> convertYoutubeSong(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final icon = getYoutubeThumbnail(video.thumbnails);
      final title = video.title.replaceAll('"', "'");

      SongModel song = SongModel(
        id: 0,
        title: title,
        icon: icon,
        url: url,
        author: video.author,
      );

      return await SongParser().parseSongBeforeSave(song);
    } finally {
      yt.close();
    }
  }

  @override
  String parseYoutubePlaylist(String url) {
    String parsedUrl = url.replaceAll('youtube.com/playlist?list=', '');
    parsedUrl = parsedUrl.replaceAll('https://', '');
    parsedUrl = parsedUrl.replaceAll('www.', '');
    return parsedUrl;
  }

  @override
  String parseYoutubeSongUrl(String url) {
    // Extract video ID from various YouTube URL formats
    final regExp = RegExp(
      r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:watch(?:\?v=|\/))|(?:\?v=|\/))([^#\&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? url;
    }
    return url;
  }

  @override
  Stream<PlaylistModel> convertYoutubePlaylist(String url) async* {
    final yt = YoutubeExplode();
    try {
      final playlist = await yt.playlists.get(parseYoutubePlaylist(url));
      final songs = <SongModel>[];

      await for (final video in yt.playlists.getVideos(playlist.id)) {
        final song = await convertYoutubeSong(video.url);
        songDataManager?.addSong(song);

        if (songDataManager != null) {
          final retrievedSong = await songDataManager!.loadLastAddedSong();
          songs.add(retrievedSong);
        } else {
          songs.add(song);
        }

        yield PlaylistModel(
          id: 0,
          title: playlist.title,
          icon: songs.isNotEmpty ? songs[0].icon : '',
          songs: List.from(songs),
        );
      }
    } finally {
      yt.close();
    }
  }

  @override
  Future<String> getHighestQualityAudioUrl(String videoId) async {
    var youtube = YoutubeExplode();
    String parsedUrl = SongParser().parseYoutubeSongUrl(videoId);
    var videoManifest =
        await youtube.videos.streamsClient.getManifest(parsedUrl);
    // var streamInf = videoManifest.audioOnly.sortByBitrate();
    // var streamInfo = streamInf[streamInf.length - 1];
    // For Highest Bitrate
    var streamInfo = videoManifest.audioOnly.withHighestBitrate();

    youtube.close();

    return streamInfo.url.path;
  }
}
