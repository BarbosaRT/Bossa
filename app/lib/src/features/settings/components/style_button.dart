import 'package:bossa/src/features/audio/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StyleButton extends StatelessWidget {
  final AudioStyle style;
  final String label;

  const StyleButton({super.key, required this.style, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioNotifier>();

    return ElevatedButton(
      onPressed: () {
        controller.changeStyle(style);
      },
      child: Text(label),);
  }
}