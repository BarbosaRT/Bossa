import 'dart:convert';
import 'dart:io';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:http/http.dart' as http;

class HttpRequester {
  http.Client client = http.Client();

  Future<dynamic> retriveFromUrl(String link) async {
    try {
      var response = jsonDecode((await client.get(Uri.parse(link))).body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

class SongParser {
  String apiUrl =
      'https://api.invidious.io/instances.json?pretty=1&sort_by=type,users';

  List<String> youtubeUrls = [
    'https://www.youtube.com/watch?v=',
    'https://youtu.be/'
  ];

  bool isSongFromYoutube(String input) {
    bool output = false;
    for (String url in youtubeUrls) {
      bool aux = input.contains(url);
      output = aux ? aux : output;
    }
    return output;
  }

  String parseYoutubeSongUrl(String input) {
    String output = input.toString();

    if (isSongFromYoutube(input)) {
      for (String url in youtubeUrls) {
        output = output.replaceAll(url, '');
      }
    }
    return output.substring(0, 11);
  }

  Future<SongModel> parseSongBeforeSave(SongModel song) async {
    if (SongParser().isSongFromYoutube(song.url)) {
      String workingDirectory = await FilePathImpl().getDocumentsDirectory();

      await Directory('$workingDirectory/songs').create();
      await DioDownloadService(filePath: FilePathImpl())
          .download(song.url, '${song.title}.m4a', '$workingDirectory/songs');
      song.path = '$workingDirectory/songs/${song.title}.m4a';

      // await Directory('$workingDirectory/icons').create();
      // await DioDownloadService(filePath: FilePathImpl())
      //     .download(song.url, '${song.title}.jpg', '$workingDirectory/icons');
      // song.icon = '$workingDirectory/icons/${song.title}.jpg';
    }
    return song;
  }
}
