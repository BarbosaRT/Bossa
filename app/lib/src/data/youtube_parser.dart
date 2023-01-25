import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:bossa/src/url/http_requester.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeParser {
  SongDataManager? songDataManager;

  YoutubeParser({this.songDataManager}) {
    songDataManager = SongDataManager(
        localDataManagerInstance: dataManagerInstance,
        downloadService: HttpDownloadService(filePath: FilePathImpl()));
  }

  String getYoutubeThumbnail(ThumbnailSet thumbnails) {
    List<String> thumbnailsList = [
      thumbnails.highResUrl,
      thumbnails.lowResUrl,
      thumbnails.maxResUrl,
      thumbnails.mediumResUrl,
      thumbnails.standardResUrl
    ];
    String icon = UIConsts.assetImage;
    for (String thumbnail in thumbnailsList) {
      if (thumbnail.isEmpty) {
        continue;
      }
      try {
        HttpRequester().retriveFromUrl(thumbnail);
        icon = thumbnail.toString();
        break;
      } catch (e) {
        continue;
      }
    }
    return icon;
  }

  Future<SongModel> convertYoutubeSong(String url) async {
    String parsedUrl = SongParser().parseYoutubeSongUrl(url);
    var yt = YoutubeExplode();

    var video = await yt.videos.get(parsedUrl);

    String icon = YoutubeParser().getYoutubeThumbnail(video.thumbnails);

    String title = video.title.replaceAll('"', "'");

    SongModel song = SongModel(
        id: 0, title: title, icon: icon, url: url, author: video.author);
    song = await SongParser().parseSongBeforeSave(song);
    yt.close();
    return song;
  }

  String parseYoutubePlaylist(String url) {
    String parsedUrl = url.replaceAll('youtube.com/playlist?list=', '');
    parsedUrl = parsedUrl.replaceAll('https://', '');
    parsedUrl = parsedUrl.replaceAll('www.', '');
    return parsedUrl;
  }

  Stream<PlaylistModel> convertYoutubePlaylist(String url) async* {
    String parsedUrl = parseYoutubePlaylist(url);

    var yt = YoutubeExplode();

    var playlist = await yt.playlists.get(parsedUrl);

    List<SongModel> songs = [];
    await for (var video in yt.playlists.getVideos(playlist.id)) {
      SongModel song = await convertYoutubeSong(video.url);
      songDataManager!.addSong(song);

      SongModel retrivedSong = await songDataManager!.loadLastAddedSong();
      songs.add(retrivedSong);
      yield PlaylistModel(
          id: 0, title: playlist.title, icon: songs[0].icon, songs: songs);
    }

    yt.close();
  }
}
