import 'package:flutter/material.dart';


class AudioPage extends StatefulWidget {
  final List songs;
  int index;

  AudioPage({Key? key, required this.songs, required this.index})
      : super(key: key);

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}