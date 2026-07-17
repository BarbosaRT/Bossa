import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:bossa/src/data/song_parser.dart';

class RobustDownloadService {
  final String url;
  final String fileName;
  final String directory;
  final bool isYouTubeUrl;

  RobustDownloadService({
    required this.url,
    required this.fileName,
    required this.directory,
    required this.isYouTubeUrl,
  });

  /// Get the full file path
  String get filePath => '$directory/$fileName';

  /// Check if file exists and is complete
  Future<bool> isFileComplete() async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

      if (isYouTubeUrl) {
        // For YouTube files, we can't easily check remote size
        // So we check if file size is reasonable (> 1MB)
        final fileSize = await file.length();
        return fileSize > 1024 * 1024; // 1MB minimum
      } else {
        // For direct HTTP downloads, check against remote file size
        final response = await http.head(Uri.parse(url));
        if (response.statusCode == 200) {
          final contentLength = response.headers['content-length'];
          if (contentLength != null) {
            final remoteSize = int.parse(contentLength);
            final localSize = await file.length();
            return localSize == remoteSize;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking file completeness: $e');
      }
    }
    return false;
  }

  /// Download with progress tracking and resumable capability
  Future<void> downloadWithProgress({
    required Function(double) onProgress,
    Map<String, String>? headers,
  }) async {
    try {
      // Ensure directory exists
      await Directory(directory).create(recursive: true);

      if (isYouTubeUrl) {
        await _downloadFromYouTube(onProgress);
      } else {
        await _downloadFromHttp(onProgress, headers);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Download error: $e');
      }
      rethrow;
    }
  }

  /// Download from YouTube with progress
  Future<void> _downloadFromYouTube(Function(double) onProgress) async {
    final youtube = YoutubeExplode();

    try {
      final videoId = SongParser().parseYoutubeSongUrl(url);
      final manifest = await youtube.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();

      final stream = youtube.videos.streamsClient.get(streamInfo);
      final file = File(filePath);
      final sink = file.openWrite();

      int downloadedBytes = 0;
      final totalBytes = streamInfo.size.totalBytes;

      await for (final chunk in stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (totalBytes > 0) {
          final progress = (downloadedBytes / totalBytes) * 100;
          onProgress(progress);
        }
      }

      await sink.flush();
      await sink.close();
      onProgress(100.0);
    } finally {
      youtube.close();
    }
  }

  /// Download from HTTP with resumable capability
  Future<void> _downloadFromHttp(
    Function(double) onProgress,
    Map<String, String>? headers,
  ) async {
    final file = File(filePath);
    int startByte = 0;

    // Check if partial file exists for resuming
    if (file.existsSync()) {
      startByte = await file.length();
    }

    final requestHeaders = <String, String>{
      if (headers != null) ...headers,
      if (startByte > 0) 'Range': 'bytes=$startByte-',
    };

    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(requestHeaders);

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 206) {
      throw HttpException('Failed to download: ${response.statusCode}');
    }

    final contentLength = response.headers['content-length'];
    final totalBytes =
        contentLength != null ? int.parse(contentLength) + startByte : null;

    final sink =
        file.openWrite(mode: startByte > 0 ? FileMode.append : FileMode.write);
    int downloadedBytes = startByte;

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (totalBytes != null && totalBytes > 0) {
          final progress = (downloadedBytes / totalBytes) * 100;
          onProgress(progress.clamp(0.0, 100.0));
        }
      }

      await sink.flush();
      onProgress(100.0);
    } finally {
      await sink.close();
    }
  }

  /// Delete the downloaded file
  Future<void> deleteFile() async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
    }
  }
}
