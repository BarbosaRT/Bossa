import 'package:bossa/src/audio/audio_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JustAudioManager', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    AudioManager audioManager = JustAudioManager();
    String testSongUrl =
        'http://commondatastorage.googleapis.com/codeskulptor-assets/week7-brrring.m4a';

    test('returns null Duration when not playing', () async {
      expect(audioManager.getDuration(), isNull);
    });

    test('load audio from URL', () async {
      audioManager.load(testSongUrl);
    });

    test('dont load audio from a wrong URL', () async {
      audioManager.load('.testurl');
    });

    // test('load audio from file path', () async {
    //   // Test loading audio from a file path
    //   audioManager.load('audio.mp3');
    // });

    test('play and pause audio', () async {
      audioManager.load(testSongUrl);
      audioManager.play();
      expect(audioManager.isPlaying(), isTrue);
      audioManager.pause();
      expect(audioManager.isPlaying(), isFalse);
    });

    test('seek to specific position', () async {
      audioManager.load(testSongUrl);
      audioManager.play();
      Duration? position = audioManager.getPosition();
      expect(position, isNotNull);

      Duration duration = const Duration(seconds: 10);
      audioManager.seek(position! + duration);
      expect(audioManager.getPosition(), equals(position + duration));
    });

    test('stop audio', () async {
      audioManager.load(testSongUrl);
      audioManager.play();
      audioManager.stop();
      expect(audioManager.isPlaying(), isFalse);
      expect(audioManager.getPosition(), Duration.zero);
    });
  });
}
