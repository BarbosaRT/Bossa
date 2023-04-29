import 'dart:async';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/audio/vlc_audio_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:dart_vlc/dart_vlc.dart' as vlc;
import 'package:dart_vlc/dart_vlc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VlcPlaylistManager implements PlaylistAudioManager {
  final player = vlcPlayerManagerInstance.player;
  PlayMode currentPlayMode = PlayMode.single;
  bool shuffle = false;

  @override
  Stream<int?> indexesStream() {
    return player.currentStream.map((event) => event.index);
  }

  @override
  Future<void> add(String path) async {
    final audioSource = vlcPlayerManagerInstance.getMedia(path);
    player.add(audioSource);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> insert(int index, String path) async {
    final audioSource = vlcPlayerManagerInstance.getMedia(path);
    player.insert(index, audioSource);
  }

  @override
  Future<void> removeAt(int index) async {
    player.remove(index);
  }

  @override
  Future<void> seek(Duration position, int index) async {
    player.seek(position);
  }

  @override
  Future<void> seekToNext() async {
    player.next();
  }

  @override
  Future<void> seekToPrevious() async {
    player.previous();
  }

  PlaylistMode getLoopMode(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.repeat:
        return PlaylistMode.repeat;
      case PlayMode.single:
        return PlaylistMode.single;
      default:
        return PlaylistMode.loop;
    }
  }

  @override
  Future<void> setPlayMode(PlayMode loopMode) async {
    currentPlayMode = loopMode;
    player.setPlaylistMode(getLoopMode(loopMode));
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    shuffle = enabled;
    return;
    //TODO: Make it work
    //code example: await player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setPlaylist(PlaylistModel playlist,
      {int initialIndex = 0, initialPosition = Duration.zero}) async {
    List<Media> songAudioSources = [];
    List<SongModel> songs = playlist.songs.toList();

    // Pre-load
    // TODO: resolver length, não funciona, musica para depois da length
    int length = playlist.songs.length > 8 ? 8 : playlist.songs.length;
    for (int index = 0; index < length; index++) {
      if (initialIndex + index >= songs.length) {
        break;
      }
      SongModel song = songs[initialIndex + index];
      String path = song.path.isEmpty ? song.url : song.path;

      // MediaItem tag = MediaItem(
      //   id: song.id.toString(),
      //   title: song.title,
      //   album: playlist.title,
      //   artUri: getUriFromString(song.icon),
      // );

      Media audioSource = await getAudioSourceFromString(path);
      songAudioSources.add(audioSource);
    }

    player.open(vlc.Playlist(medias: songAudioSources));

    // Loads the other part of the songs
    for (int index = initialIndex + length; index < songs.length; index++) {
      SongModel song = songs[index];
      String path = song.path.isEmpty ? song.url : song.path;

      // MediaItem tag = MediaItem(
      //   id: song.id.toString(),
      //   title: song.title,
      //   album: playlist.title,
      //   artUri: getUriFromString(song.icon),
      // );

      await add(path);
    }

    // Loads the first part
    for (int index = 0; index < initialIndex; index++) {
      SongModel song = songs[index];
      String path = song.path.isEmpty ? song.url : song.path;

      // MediaItem tag = MediaItem(
      //   id: song.id.toString(),
      //   title: song.title,
      //   album: playlist.title,
      //   artUri: getUriFromString(song.icon),
      // );

      await add(path);
    }
  }

  Uri getUriFromString(String string) {
    if (UrlParser.validUrl(string)) {
      return Uri.parse(string);
    } else {
      return Uri.file(string);
    }
  }

  Future<Media> getAudioSourceFromString(
    String string,
    //{MediaItem? tag}
  ) async {
    if (SongParser().isSongFromYoutube(string)) {
      var youtube = YoutubeExplode();
      String parsedUrl = SongParser().parseYoutubeSongUrl(string);
      var videoManifest =
          await youtube.videos.streamsClient.getManifest(parsedUrl);
      // var streamInf = videoManifest.audioOnly.sortByBitrate();
      // var streamInfo = streamInf[streamInf.length - 1];
      // For Highest Bitrate
      var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      //youtube.close();
      return Media.network(streamInfo.url);
    }
    return vlcPlayerManagerInstance.getMedia(string);
  }

  @override
  Stream<PlayMode> playModeStream() {
    return Stream.value(currentPlayMode);
  }

  @override
  Stream<bool> shuffleModeEnabledStream() {
    return Stream.value(shuffle);
  }

  PlaylistMode getPlayMode(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.repeat:
        return PlaylistMode.repeat;
      case PlayMode.single:
        return PlaylistMode.single;
      default:
        return PlaylistMode.loop;
    }
  }
}
