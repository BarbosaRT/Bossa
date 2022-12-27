import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const TestPage()),
      ];
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<SongModel> songs = [];
  final songDataManager = SongDataManager();
  final manager = JustAudioManager();

  @override
  void initState() {
    super.initState();
    songDataManager.loadSongs().then((value) {
      setState(() {
        songs = value.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Column(children: [
        Expanded(
          child: TextButton(
              onPressed: () {
                final song = SongModel(
                    id: 2,
                    title: 'Song 1',
                    icon: 'icon1',
                    url: 'https://youtu.be/NgYoUsdETRw',
                    path: 'path1');
                songDataManager.addSong(song);
              },
              child: const Text('Add Song')),
        ),
        Expanded(
            child: Column(
          children: [
            const Text('Songs'),
            for (SongModel song in songs)
              Column(children: [
                Text(song.title),
                IconButton(
                    onPressed: () {
                      manager.load(song.url);
                      manager.play();
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ))
              ])
          ],
        ))
      ]),
    );
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wave',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
            trackVisibility:
                MaterialStateProperty.resolveWith((states) => true)),
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
