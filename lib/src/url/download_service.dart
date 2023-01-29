import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:http/http.dart' show get;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class DownloadService {
  Future<void> download(String url, String path, String directory);
}

class HttpDownloadService implements DownloadService {
  FilePath filePath;

  HttpDownloadService({required this.filePath});

  Future<void> downloadIcon(
      String url, String fileName, String directory) async {
    if (Platform.isAndroid) {
      bool hasPermission = await _requestWritePermission();
      if (!hasPermission) throw Exception('Permission Denied');
    }
    if (!UrlParser.validUrl(url)) {
      return;
    }

    var response = await get(Uri.parse(url));
    final image = img.JpegDecoder().decode(response.bodyBytes);

    const widthRatio = 7 / 32;
    const heightRatio = 1 / 8;

    final xPadding = (image!.width * widthRatio).toInt();
    final yPadding = (image.height * heightRatio).toInt();

    final croppedImage = img.copyCrop(
      image,
      x: xPadding,
      y: yPadding,
      width: image.width - xPadding * 2,
      height: image.height - yPadding * 2,
    );

    final outputImage = img.JpegEncoder().encode(croppedImage);

    var file = File('$directory/$fileName');
    await file.writeAsBytes(outputImage);
  }

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
