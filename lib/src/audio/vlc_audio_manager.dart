import 'dart:io';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/url/url_parser.dart';
import 'package:dart_vlc/dart_vlc.dart';

VlcPlayerManager vlcPlayerManagerInstance = VlcPlayerManager();

class VlcPlayerManager implements AudioManager {
  final player = Player(
    id: 69420,
    commandlineArguments: ['--no-video'],
  );

  @override
  Stream<bool> playingStream() {
    return player.playbackStream.map((event) => event.isPlaying);
  }

  @override
  Future<Duration> getPosition() async {
    return player.position.position ?? Duration.zero;
  }

  @override
  Stream<Duration?> getDurationStream() {
    return player.positionStream.map((event) => event.duration);
  }

  @override
  Stream<Duration> getPositionStream() {
    return player.positionStream
        .map((event) => event.position ?? Duration.zero);
  }

  @override
  bool isPlaying() {
    return player.playback.isPlaying;
  }

  @override
  Future<void> load(String path) async {
    player.open(getMedia(path));
  }

  Media getMedia(String path) {
    if (UrlParser.validUrl(path)) {
      return Media.network(path);
    } else {
      return Media.file(File(path));
    }
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> play() async {
    player.play();
  }

  @override
  void seek(Duration position) {
    player.seek(position);
  }

  @override
  void stop() {
    player.stop();
  }

  @override
  Future<void> dispose() async {
    player.dispose();
  }
}
