import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:bossa/src/features/audio/views/classic/classic_view.dart';
import 'package:bossa/src/features/audio/views/modern/modern_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioNotifier>();

    return audioController.audioStyle == AudioStyle.modern 
    ? const ModernAudioPage() 
    : const ClassicAudioPage();
  }
}