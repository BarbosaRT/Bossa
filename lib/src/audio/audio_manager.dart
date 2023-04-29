abstract class AudioManager {
  Future<void> load(String path);
  Future<void> play();
  Future<void> pause();
  void stop();
  void seek(Duration position);
  Future<void> dispose();
  bool isPlaying();
  Future<Duration> getPosition();
  Stream<Duration> getPositionStream();
  Stream<Duration?> getDurationStream();
  Stream<bool> playingStream();
}
