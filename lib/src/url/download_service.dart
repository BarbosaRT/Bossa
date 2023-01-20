import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadService {
  Future<void> download(String url, String path, String directory);
}

class DioDownloadService implements DownloadService {
  FilePath filePath;

  DioDownloadService({required this.filePath});

  Future<void> downloadIcon(
      String url, String fileName, String directory) async {}

  @override
  Future<void> download(String url, String fileName, String directory) async {
    if (Platform.isAndroid) {
      bool hasPermission = await _requestWritePermission();
      if (!hasPermission) throw Exception('Permission Denied');
    }

    var youtube = YoutubeExplode();
    var videoManifest = await youtube.videos.streamsClient
        .getManifest(SongParser().parseYoutubeSongUrl(url));

    var streamInfo = videoManifest.audioOnly.withHighestBitrate();

    var stream = youtube.videos.streamsClient.get(streamInfo);

    var file = File('$directory/$fileName');
    var fileStream = file.openWrite();

    await stream.pipe(fileStream);

    await fileStream.flush();
    await fileStream.close();
    youtube.close();
  }

  // Requests storage permission
  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }
}
