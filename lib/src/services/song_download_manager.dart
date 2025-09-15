import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/services/robust_download_service.dart';
import 'package:image/image.dart' as img;

/// Download progress callback
typedef ProgressCallback = void Function(double progress);

class SongDownloadManager {
  final FilePathImpl _filePath = FilePathImpl();

  /// Download a song with progress tracking
  Future<SongModel> downloadSong(
    SongModel song, {
    required ProgressCallback onProgress,
    bool downloadOffline = false,
  }) async {
    if (!downloadOffline) {
      return song;
    }

    try {
      final workingDirectory = await _filePath.getDocumentsDirectory();

      if (SongParser().isSongFromYoutube(song.url)) {
        return await _downloadYouTubeSong(song, workingDirectory, onProgress);
      } else {
        return await _downloadDirectSong(song, workingDirectory, onProgress);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading song: $e');
      }
      rethrow;
    }
  }

  /// Download YouTube song with icon
  Future<SongModel> _downloadYouTubeSong(
    SongModel song,
    String workingDirectory,
    ProgressCallback onProgress,
  ) async {
    final fileName = SongParser().parseYoutubeSongUrl(song.url);
    final iconPath = '$workingDirectory/icons/$fileName.jpg';
    final songPath = '$workingDirectory/songs/$fileName.m4a';

    // Download icon (25% of progress)
    if (!await File(iconPath).exists()) {
      final iconDownloader = RobustDownloadService(
        url: song.icon,
        fileName: '$fileName.jpg',
        directory: '$workingDirectory/icons',
        isYouTubeUrl: false,
      );

      await iconDownloader.downloadWithProgress(
        onProgress: (progress) => onProgress(progress * 0.25),
      );

      // Process the icon (crop YouTube thumbnail)
      await _processYouTubeIcon(iconPath);
    } else {
      onProgress(25.0);
    }

    // Download song (75% of progress)
    if (!await File(songPath).exists()) {
      final songDownloader = RobustDownloadService(
        url: song.url,
        fileName: '$fileName.m4a',
        directory: '$workingDirectory/songs',
        isYouTubeUrl: true,
      );

      await songDownloader.downloadWithProgress(
        onProgress: (progress) => onProgress(25.0 + (progress * 0.75)),
      );
    } else {
      onProgress(100.0);
    }

    // Update song paths
    song.icon = iconPath;
    song.path = songPath;

    return song;
  }

  /// Download direct URL song
  Future<SongModel> _downloadDirectSong(
    SongModel song,
    String workingDirectory,
    ProgressCallback onProgress,
  ) async {
    final uri = Uri.parse(song.url);
    final fileName = uri.pathSegments.last;
    final songPath = '$workingDirectory/songs/$fileName';

    if (!await File(songPath).exists()) {
      final songDownloader = RobustDownloadService(
        url: song.url,
        fileName: fileName,
        directory: '$workingDirectory/songs',
        isYouTubeUrl: false,
      );

      await songDownloader.downloadWithProgress(
        onProgress: onProgress,
      );
    } else {
      onProgress(100.0);
    }

    song.path = songPath;
    return song;
  }

  /// Process YouTube icon by cropping it
  Future<void> _processYouTubeIcon(String iconPath) async {
    try {
      final file = File(iconPath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        const widthRatio = 7 / 32;
        const heightRatio = 1 / 8;

        final xPadding = (image.width * widthRatio).toInt();
        final yPadding = (image.height * heightRatio).toInt();

        final croppedImage = img.copyCrop(
          image,
          x: xPadding,
          y: yPadding,
          width: image.width - xPadding * 2,
          height: image.height - yPadding * 2,
        );

        final outputBytes = img.encodeJpg(croppedImage);
        await file.writeAsBytes(outputBytes);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing icon: $e');
      }
    }
  }

  /// Check if song is already downloaded
  Future<bool> isSongDownloaded(SongModel song) async {
    if (song.path.isEmpty) return false;

    final file = File(song.path);
    if (!file.existsSync()) return false;

    // Check if file is not corrupted (has reasonable size)
    final fileSize = await file.length();
    return fileSize > 1024 * 100; // 100KB minimum
  }

  /// Delete downloaded song files
  Future<void> deleteSongFiles(SongModel song) async {
    try {
      if (song.path.isNotEmpty) {
        final songFile = File(song.path);
        if (songFile.existsSync()) {
          await songFile.delete();
        }
      }

      if (song.icon.isNotEmpty && !song.icon.startsWith('assets/')) {
        final iconFile = File(song.icon);
        if (iconFile.existsSync()) {
          await iconFile.delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting song files: $e');
      }
    }
  }

  /// Get download progress for a song (if currently downloading)
  Future<double> getDownloadProgress(SongModel song) async {
    // This would be implemented with a download state manager
    // For now, return 0 if not downloaded, 100 if downloaded
    return await isSongDownloaded(song) ? 100.0 : 0.0;
  }
}
