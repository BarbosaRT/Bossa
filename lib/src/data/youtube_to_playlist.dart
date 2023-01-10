import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:html/parser.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeParser {
  SongDataManager? songDataManager;

  YoutubeParser({this.songDataManager}) {
    songDataManager = SongDataManager(
        localDataManagerInstance: dataManagerInstance,
        downloadService: DioDownloadService(filePath: FilePathImpl()));
  }

  Future<SongModel> convertYoutubeSong(String url) async {
    String parsedUrl = SongParser().parseYoutubeSongUrl(url);
    var yt = YoutubeExplode();

    var video = await yt.videos.get(parsedUrl);
    ThumbnailSet thumbnails = video.thumbnails;
    String icon = thumbnails.standardResUrl.isEmpty
        ? thumbnails.lowResUrl
        : thumbnails.standardResUrl;

    String title = video.title.replaceAll('"', "'");

    SongModel song = SongModel(id: 0, title: title, icon: icon, url: url);
    song = await SongParser().parseSongBeforeSave(song);
    yt.close();
    return song;
  }

  Future<PlaylistModel> convertYoutubePlaylist(String url) async {
    String parsedUrl = url.replaceAll('youtube.com/playlist?list=', '');
    parsedUrl = parsedUrl.replaceAll('https://', '');
    parsedUrl = parsedUrl.replaceAll('www.', '');

    var yt = YoutubeExplode();

    var playlist = await yt.playlists.get(parsedUrl);

    List<SongModel> songs = [];
    await for (var video in yt.playlists.getVideos(playlist.id)) {
      SongModel song = await convertYoutubeSong(video.url);
      songDataManager!.addSong(song);

      SongModel retrivedSong = await songDataManager!.loadLastAddedSong();
      songs.add(retrivedSong);
    }

    yt.close();

    return PlaylistModel(
        id: 0, title: playlist.title, icon: songs[0].icon, songs: songs);
  }
}
