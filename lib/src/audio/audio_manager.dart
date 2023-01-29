// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:just_audio/just_audio.dart';

import 'package:bossa/src/url/url_parser.dart';

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
  Stream<Duration?> getDurationStream();
}

AudioManager audioManagerInstance = JustAudioManager();
JustAudioManager justAudioManagerInstance = JustAudioManager();

class JustAudioManager implements AudioManager {
  var player = AudioPlayer();

  JustAudioManager() {
    AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();
    loudnessEnhancer.setEnabled(true);
    loudnessEnhancer.setTargetGain(40);
    AudioPipeline audioPipeline =
        AudioPipeline(androidAudioEffects: [loudnessEnhancer]);
    player = AudioPlayer(audioPipeline: audioPipeline);
    player.setSkipSilenceEnabled(true);
  }

  @override
  Duration getPosition() {
    return player.position;
  }

  @override
  Stream<Duration?> getDurationStream() {
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
      await player.setUrl(path, preload: true);
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
