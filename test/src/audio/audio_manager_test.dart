import 'package:bossa/src/audio/audio_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JustAudioManager', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    AudioManager audioManager = JustAudioManager();
    String testSongUrl =
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    test('load audio from URL', () async {
      // Test loading audio from a URL
      audioManager.load(testSongUrl);
    });

    // test('load audio from file path', () async {
    //   // Test loading audio from a file path
    //   audioManager.load('audio.mp3');
    // });

    test('play and pause audio', () async {
      // Test playing and pausing audio
      audioManager.load(testSongUrl);
      audioManager.play();
      expect(audioManager.isPlaying(), isTrue);
      audioManager.pause();
      expect(audioManager.isPlaying(), isFalse);
    });

    test('seek to specific position', () async {
      // Test seeking to a specific position in the audio
      audioManager.load(testSongUrl);
      audioManager.play();
      Duration? position = audioManager.getPosition();
      expect(position, isNotNull);

      Duration duration = const Duration(seconds: 10);
      audioManager.seek(position! + duration);
      expect(audioManager.getPosition(), equals(position + duration));
    });

    test('stop audio', () async {
      // Test stopping audio
      audioManager.load(testSongUrl);
      audioManager.play();
      audioManager.stop();
      expect(audioManager.isPlaying(), isFalse);
      expect(audioManager.getPosition(), Duration.zero);
    });
  });
}
