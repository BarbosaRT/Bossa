import 'dart:async';
import 'package:bossa/models/playlist_model.dart';

abstract class PlaylistAudioManager {
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, Duration initialPosition = Duration.zero});
  Future<void> seekToNext();
  Future<void> seekToPrevious();
  Future<void> seek(Duration position, int index);
  Future<void> setPlayMode(PlayMode loopMode);
  Stream<PlayMode> playModeStream();

  Future<void> setShuffleModeEnabled(bool enabled);
  Stream<bool> shuffleModeEnabledStream();

  Future<void> add(String path);
  Future<void> insert(int index, String path);
  Future<void> removeAt(int index);
  Stream<int?> indexesStream();
}

enum PlayMode { loop, repeat, single }
