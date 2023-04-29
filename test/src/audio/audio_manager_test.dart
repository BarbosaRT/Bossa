import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/audio/just_audio_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JustAudioManager', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    AudioManager audioManager = JustAudioManager();
    String testSongUrl =
        'http://commondatastorage.googleapis.com/codeskulptor-assets/week7-brrring.m4a';

    test('load audio from URL', () async {
      audioManager.load(testSongUrl);
      audioManager.play();
    });

    test('play and pause audio', () async {
      audioManager.load(testSongUrl);
      audioManager.play();
      expect(audioManager.isPlaying(), isTrue);
      audioManager.pause();
      expect(audioManager.isPlaying(), isFalse);
    });

    test('seek to specific position', () async {
      AudioManager audioManager = JustAudioManager();
      audioManager.load(testSongUrl);
      audioManager.play();
      Duration? position = await audioManager.getPosition();
      expect(position, isNotNull);

      Duration duration = const Duration(seconds: 10);
      audioManager.seek(position + duration);
      expect(audioManager.getPosition(), equals(position + duration));
    });

    test('stop audio', () async {
      AudioManager audioManager = JustAudioManager();
      audioManager.load(testSongUrl);
      audioManager.play();
      audioManager.stop();
      expect(audioManager.isPlaying(), isFalse);
      expect(audioManager.getPosition(), Duration.zero);
    });

    test('getPositionStream() returns a stream of positions', () async {
      await audioManager.load(testSongUrl);
      audioManager.play();
      Future.delayed(const Duration(seconds: 3));

      audioManager.pause();
      final positionStream = audioManager.getPositionStream();
      positionStream.listen(
        expectAsync1(
          (event) {
            expect(event, isA<Duration>());
          },
        ),
      );
      expect(positionStream, isA<Stream<Duration>>());
    });

    test('dispose() closes the audio player', () async {
      await audioManager.load(testSongUrl);
      audioManager.play();
      await audioManager.dispose();
    });
  });
}
