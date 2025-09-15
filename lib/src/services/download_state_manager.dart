import 'dart:async';
import 'package:flutter/foundation.dart';

enum DownloadStatus {
  idle,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadState {
  final String id;
  final DownloadStatus status;
  final double progress;
  final String? error;

  const DownloadState({
    required this.id,
    required this.status,
    required this.progress,
    this.error,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
  }) {
    return DownloadState(
      id: id,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

class DownloadStateManager extends ChangeNotifier {
  static final DownloadStateManager _instance =
      DownloadStateManager._internal();
  factory DownloadStateManager() => _instance;
  DownloadStateManager._internal();

  final Map<String, DownloadState> _downloads = {};
  final Map<String, Completer<void>> _completers = {};

  /// Get current download state for an ID
  DownloadState? getDownloadState(String id) {
    return _downloads[id];
  }

  /// Get all current downloads
  Map<String, DownloadState> get allDownloads => Map.unmodifiable(_downloads);

  /// Start tracking a download
  void startDownload(String id) {
    _downloads[id] = DownloadState(
      id: id,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );
    _completers[id] = Completer<void>();
    notifyListeners();
  }

  /// Update download progress
  void updateProgress(String id, double progress) {
    final current = _downloads[id];
    if (current != null && current.status == DownloadStatus.downloading) {
      _downloads[id] = current.copyWith(progress: progress.clamp(0.0, 100.0));
      notifyListeners();
    }
  }

  /// Mark download as completed
  void completeDownload(String id) {
    final current = _downloads[id];
    if (current != null) {
      _downloads[id] = current.copyWith(
        status: DownloadStatus.completed,
        progress: 100.0,
      );
      _completers[id]?.complete();
      _completers.remove(id);
      notifyListeners();

      // Remove completed downloads after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _downloads.remove(id);
        notifyListeners();
      });
    }
  }

  /// Mark download as failed
  void failDownload(String id, String error) {
    final current = _downloads[id];
    if (current != null) {
      _downloads[id] = current.copyWith(
        status: DownloadStatus.failed,
        error: error,
      );
      _completers[id]?.completeError(Exception(error));
      _completers.remove(id);
      notifyListeners();
    }
  }

  /// Cancel a download
  void cancelDownload(String id) {
    final current = _downloads[id];
    if (current != null) {
      _downloads[id] = current.copyWith(status: DownloadStatus.cancelled);
      _completers[id]?.completeError(Exception('Download cancelled'));
      _completers.remove(id);
      notifyListeners();
    }
  }

  /// Wait for download to complete
  Future<void> waitForDownload(String id) async {
    final completer = _completers[id];
    if (completer != null) {
      return completer.future;
    }
  }

  /// Check if download is in progress
  bool isDownloading(String id) {
    final state = _downloads[id];
    return state?.status == DownloadStatus.downloading;
  }

  /// Get download progress (0-100)
  double getProgress(String id) {
    final state = _downloads[id];
    return state?.progress ?? 0.0;
  }

  /// Clear all downloads
  void clearAll() {
    _downloads.clear();
    for (final completer in _completers.values) {
      completer.completeError(Exception('Downloads cleared'));
    }
    _completers.clear();
    notifyListeners();
  }
}
