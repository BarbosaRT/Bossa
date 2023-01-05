import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';

class YoutubeToPlaylist {
  Future<String> getInvidiousApiInstance() async {
    String apiUrl =
        'https://api.invidious.io/instances.json?pretty=1&sort_by=type,users';
    List<dynamic> invidiousInstances =
        await HttpRequest().retriveFromUrl(apiUrl) as List<dynamic>;
    String invidiousInstance = '';
    for (dynamic instance in invidiousInstances) {
      if (instance.runtimeType == String) continue;
      if (instance[1]['api'] == true) {
        invidiousInstance = instance[1]['uri'] as String;
        break;
      }
    }
    return invidiousInstance;
  }

  Future<PlaylistModel> convertYoutubePlaylist(String url) async {
    String invidiousInstance = await getInvidiousApiInstance();
    String parsedUrl = url.substring(url.length - 34, url.length);
    Map<String, dynamic> result = await HttpRequest()
            .retriveFromUrl('$invidiousInstance/api/v1/playlists/$parsedUrl')
        as Map<String, dynamic>;

    List<SongModel> songs = [];
    for (Map<String, dynamic> video in result['videos']) {
      if (video['title'] == '[Private video]') continue;
      String title = video['title'] as String;
      String url = video['videoId'] as String;

      String icon = '';
      List<dynamic> thumbnails = video['videoThumbnails'] as List<dynamic>;
      for (dynamic thumb in thumbnails) {
        if (thumb['width'] as int <= 640) {
          icon = thumb['url'] as String;
        }
      }

      SongModel song =
          SongModel(id: 0, title: title, icon: icon, url: url, path: '');

      songs.add(song);
    }

    String title = result['title'] as String;
    return PlaylistModel(
        id: 0, title: title, icon: songs[0].icon, songs: songs);
  }
}
