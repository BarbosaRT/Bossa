import 'package:just_audio/just_audio.dart';

abstract class AudioManager {
  void load(String path);
  void play();
  void pause();
  void stop();
  void seek(Duration position);
  bool isPlaying();
  Duration? getPosition();
  Duration? getDuration();
}

class JustAudioManager implements AudioManager {
  final player = AudioPlayer();

  @override
  Duration? getDuration() {
    return player.duration;
  }

  @override
  Duration getPosition() {
    return player.position;
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
      player.setUrl(path);
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
}
