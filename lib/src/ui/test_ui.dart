import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/ui/test/playlist_add_widget.dart';
import 'package:bossa/src/ui/test/playlist_container.dart';
import 'package:bossa/src/ui/test/song_add_widget.dart';
import 'package:bossa/src/ui/test/song_container.dart';
import 'package:flutter/material.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final songDataManager = SongDataManager();
  List<SongModel> songs = [];

  final playlistDataManager = PlaylistDataManager();
  List<PlaylistModel> playlists = [];

  final manager = JustAudioManager();
  GlobalKey<SongAddWidgetState> songAddKey = GlobalKey();
  bool editing = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
    loadPlaylists();
  }

  void loadSongs() async {
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  void loadPlaylists() async {
    playlists = await playlistDataManager.loadPlaylists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<SongContainer> songContainers = [];
    for (SongModel song in songs) {
      songContainers.add(
        SongContainer(
          song: song,
          callback: () {
            loadSongs();
          },
          editCallback: () {
            songAddKey.currentState?.insertSongToBeAdded(song);
          },
        ),
      );
    }

    List<PlaylistContainer> playlistContainers = [];
    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        PlaylistContainer(
          callback: () {
            loadPlaylists();
          },
          playlist: playlist,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: SongAddWidget(
                key: songAddKey,
                callback: () {
                  loadSongs();
                },
              ),
            ),
            Positioned(
              top: 140,
              child: SizedBox(
                width: 400,
                height: 250,
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.zero,
                  children: songContainers,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 500,
              child: PlaylistAddWidget(
                callback: () {
                  loadPlaylists();
                },
              ),
            ),
            Positioned(
              top: 200,
              left: 400,
              child: SizedBox(
                width: 700,
                height: 180,
                child: GridView.count(
                  crossAxisCount: 2,
                  children: playlistContainers,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
