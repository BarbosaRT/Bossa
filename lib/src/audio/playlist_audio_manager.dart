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

  Future<void> add(AudioSource audioSource);
  Future<void> insert(int index, AudioSource audioSource);
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
  Future<void> add(AudioSource audioSource) async {
    await playlistAudioSource.add(audioSource);
  }

  @override
  Future<void> insert(int index, AudioSource audioSource) async {
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
    List<AudioSource> songAudioSources = [];
    List<SongModel> songs = playlist.songs.toList();

    print('print: $initialIndex ${songs[0].title}');

    // Pre-load
    int length = playlist.songs.length > 2 ? 2 : playlist.songs.length;
    for (int index = 0; index < length; index++) {
      if (initialIndex + index >= songs.length) {
        break;
      }
      SongModel song = songs[initialIndex + index];
      String path = song.path.isEmpty ? song.url : song.path;

      MediaItem tag = MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: playlist.title,
        artUri: getUriFromString(song.icon),
      );

      AudioSource audioSource = await getAudioSourceFromString(path, tag: tag);
      songAudioSources.add(audioSource);
    }

    playlistAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: songAudioSources,
    );

    await player.setAudioSource(playlistAudioSource,
        initialPosition: initialPosition);
    await setLoopMode(LoopMode.all);

    // Loads the other part of the songs
    for (int index = initialIndex + length; index < songs.length; index++) {
      SongModel song = songs[index];
      String path = song.path.isEmpty ? song.url : song.path;

      MediaItem tag = MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: playlist.title,
        artUri: getUriFromString(song.icon),
      );

      AudioSource audioSource = await getAudioSourceFromString(path, tag: tag);
      await add(audioSource);
    }

    // Loads the first part
    for (int index = 0; index < initialIndex; index++) {
      SongModel song = songs[index];
      String path = song.path.isEmpty ? song.url : song.path;

      MediaItem tag = MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: playlist.title,
        artUri: getUriFromString(song.icon),
      );

      AudioSource audioSource = await getAudioSourceFromString(path, tag: tag);
      await add(audioSource);
    }
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
      // var streamInf = videoManifest.audioOnly.sortByBitrate();
      // var streamInfo = streamInf[streamInf.length - 1];
      // For Highest Bitrate
      var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      youtube.close();

      return LockCachingAudioSource(
        streamInfo.url,
        tag: tag,
      );
    }
    return AudioSource.uri(getUriFromString(string), tag: tag);
  }
}
