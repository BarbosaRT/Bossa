import 'dart:io';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';

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
      String fileName = parseYoutubeSongUrl(song.url);
      await Directory('$workingDirectory/icons').create();
      await HttpDownloadService(filePath: FilePathImpl()).downloadIcon(
          song.icon.toString(), '$fileName.jpg', '$workingDirectory/icons');

      song.icon = '$workingDirectory/icons/$fileName.jpg';

      await Directory('$workingDirectory/songs').create();
      await HttpDownloadService(filePath: FilePathImpl())
          .download(song.url, '$fileName.m4a', '$workingDirectory/songs');
      song.path = '$workingDirectory/songs/$fileName.m4a';
    }
    return song;
  }
}
