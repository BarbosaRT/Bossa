import 'dart:async';

import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:just_audio/just_audio.dart';
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
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, initialPosition = Duration.zero}) async {
    List<AudioSource> songs = [];

    for (SongModel song in playlist.songs) {
      String path = song.path.isEmpty ? song.url : song.path;
      AudioSource audioSource = await getAudioSourceFromString(path);
      songs.add(audioSource);
    }

    playlistAudioSource = ConcatenatingAudioSource(
      useLazyPreparation: true,
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

  Future<AudioSource> getAudioSourceFromString(String string) async {
    AudioSource? youtubeAudioSource =
        await tryGetAudioSourceFromYoutube(string);
    if (youtubeAudioSource != null) {
      return youtubeAudioSource;
    }
    if (UrlParser.validUrl(string)) {
      return AudioSource.uri(Uri.parse(string));
    } else {
      return AudioSource.uri(Uri.file(string));
    }
  }

  Future<AudioSource?> tryGetAudioSourceFromYoutube(String string) async {
    if (SongParser().isSongFromYoutube(string)) {
      var youtube = YoutubeExplode();
      var videoManifest = await youtube.videos.streamsClient
          .getManifest(SongParser().parseYoutubeSongUrl(string));
      var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      List<int> bytes = [];
      var stream = youtube.videos.streamsClient.get(streamInfo);
      await for (var bytesList in stream) {
        bytes += bytesList;
      }
      youtube.close();
      return YoutubeStreamSource(bytes);
    }
    return null;
  }
}

class YoutubeStreamSource extends StreamAudioSource {
  final List<int> bytes;
  YoutubeStreamSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/raw',
    );
  }
}
