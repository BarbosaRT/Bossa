import 'package:bossa/src/url/url_parser.dart';
import 'package:just_audio/just_audio.dart';

abstract class AudioManager {
  Future<void> load(String path);
  void play();
  void pause();
  void stop();
  void seek(Duration position);
  Future<void> dispose();
  bool isPlaying();
  Duration getPosition();
  Stream<Duration> getPositionStream();
  Stream<Duration?> getDuration();
}

JustAudioManager justAudioManagerInstance = JustAudioManager();

class JustAudioManager implements AudioManager {
  final player = AudioPlayer();

  @override
  Duration getPosition() {
    return player.position;
  }

  @override
  Stream<Duration?> getDuration() {
    return player.durationStream;
  }

  @override
  Stream<Duration> getPositionStream() {
    return player.positionStream;
  }

  @override
  bool isPlaying() {
    return player.playing;
  }

  @override
  Future<void> load(String path) async {
    if (UrlParser.validUrl(path)) {
      await player.setUrl(path, preload: false);
    } else {
      await player.setFilePath(path);
    }
  }

  @override
  void pause() {
    player.pause();
  }

  @override
  void play() {
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
    await player.dispose();
  }
}
