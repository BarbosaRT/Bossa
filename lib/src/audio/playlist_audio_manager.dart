import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:just_audio/just_audio.dart';

abstract class PlaylistAudioManager {
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, Duration initialPosition = Duration.zero});
  Future<void> seekToNext();
  Future<void> seekToPrevious();
  Future<void> seek(Duration position, int index);
  Future<void> setLoopMode(LoopMode loopMode);
  Future<void> setShuffleModeEnabled(bool enabled);

  Future<void> add(String path);
  Future<void> insert(int index, String path);
  Future<void> removeAt(int index);
}

class JustPlaylistManager implements PlaylistAudioManager {
  final player = justAudioManagerInstance.player;
  ConcatenatingAudioSource playlistAudioSource = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );

  @override
  Future<void> add(String path) async {
    await playlistAudioSource.add(getAudioSourceFromString(path));
  }

  @override
  Future<void> insert(int index, String path) async {
    await playlistAudioSource.insert(index, getAudioSourceFromString(path));
  }

  @override
  Future<void> removeAt(int index) async {
    await playlistAudioSource.removeAt(index);
  }

  @override
  Future<void> seek(Duration position, int index) async {
    await player.seek(position, index: index);
  }

  @override
  Future<void> seekToNext() async {
    await player.seekToNext();
  }

  @override
  Future<void> seekToPrevious() async {
    await player.seekToPrevious();
  }

  @override
  Future<void> setLoopMode(LoopMode loopMode) async {
    await player.setLoopMode(loopMode);
  }

  @override
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, initialPosition = Duration.zero}) async {
    List<AudioSource> songs = [];

    for (SongModel song in playlist.songs) {
      String path = song.path.isEmpty ? song.url : song.path;
      songs.add(getAudioSourceFromString(path));
    }

    playlistAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: false,
      shuffleOrder: DefaultShuffleOrder(),
      children: songs,
    );

    await player.setAudioSource(playlistAudioSource,
        initialIndex: initialIndex, initialPosition: initialPosition);
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await player.setShuffleModeEnabled(enabled);
  }

  AudioSource getAudioSourceFromString(String string) {
    if (UrlParser.validUrl(string)) {
      return AudioSource.uri(Uri.parse(string));
    } else {
      return AudioSource.uri(Uri.file(string));
    }
  }
}
