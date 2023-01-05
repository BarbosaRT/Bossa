import 'package:just_audio/just_audio.dart';

abstract class AudioManager {
  void load(String path);
  void play();
  void pause();
  void stop();
  void seek(Duration position);
  void dispose();
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

  bool validUrl(String path) {
    try {
      return (Uri.parse(path)).isAbsolute;
    } catch (e) {
      return false;
    }
  }

  @override
  void load(String path) {
    if (validUrl(path)) {
      player.setUrl(path, preload: false);
    } else {
      player.setFilePath(path);
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
  void dispose() {
    player.dispose();
  }
}
