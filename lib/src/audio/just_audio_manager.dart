import 'package:bossa/src/audio/audio_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:bossa/src/url/url_parser.dart';

JustAudioManager justAudioManagerInstance = JustAudioManager();

class JustAudioManager implements AudioManager {
  var player = AudioPlayer();

  JustAudioManager() {
    //AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();
    //loudnessEnhancer.setEnabled(true);
    //loudnessEnhancer.setTargetGain(40);
    // AudioPipeline audioPipeline =
    //     AudioPipeline(androidAudioEffects: [loudnessEnhancer]);
    //player = AudioPlayer(audioPipeline: audioPipeline);
    player.setSkipSilenceEnabled(true);
  }

  @override
  Stream<bool> playingStream() {
    return player.playingStream;
  }

  @override
  Future<Duration> getPosition() async {
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
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> play() async {
    await player.play();
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
