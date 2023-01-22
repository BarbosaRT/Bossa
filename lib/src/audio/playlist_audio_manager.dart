import 'dart:async';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

  List<bool> isYoutubeSongList = [];

  @override
  Future<void> add(String path) async {
    AudioSource audioSource = await getAudioSourceFromString(path);
    await playlistAudioSource.add(audioSource);
  }

  @override
  Future<void> insert(int index, String path) async {
    AudioSource audioSource = await getAudioSourceFromString(path);
    await playlistAudioSource.insert(index, audioSource);
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
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, initialPosition = Duration.zero}) async {
    List<AudioSource> songs = [];

    for (SongModel song in playlist.songs) {
      String path = song.path.isEmpty ? song.url : song.path;

      MediaItem tag = MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: playlist.title,
        artUri: getUriFromString(song.icon),
      );

      AudioSource audioSource = await getAudioSourceFromString(path, tag: tag);
      songs.add(audioSource);
      isYoutubeSongList.add(SongParser().isSongFromYoutube(path));
    }

    playlistAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: songs,
    );

    await player.setAudioSource(playlistAudioSource,
        initialIndex: initialIndex, initialPosition: initialPosition);
  }

  Uri getUriFromString(String string) {
    if (UrlParser.validUrl(string)) {
      return Uri.parse(string);
    } else {
      return Uri.file(string);
    }
  }

  Future<AudioSource> getAudioSourceFromString(String string,
      {MediaItem? tag}) async {
    if (SongParser().isSongFromYoutube(string)) {
      var youtube = YoutubeExplode();
      String parsedUrl = SongParser().parseYoutubeSongUrl(string);
      var videoManifest =
          await youtube.videos.streamsClient.getManifest(parsedUrl);

      var streamInf = videoManifest.audioOnly.sortByBitrate();
      var streamInfo = streamInf[streamInf.length - 1];
      // For Highest Bitrate
      // var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      return LockCachingAudioSource(
        streamInfo.url,
        tag: tag,
      );
    }
    return AudioSource.uri(getUriFromString(string), tag: tag);
  }
}
