import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/ui/test/playlist_add_widget.dart';
import 'package:bossa/src/ui/test/playlist_container.dart';
import 'package:bossa/src/ui/test/song_add_widget.dart';
import 'package:bossa/src/ui/test/song_container.dart';
import 'package:bossa/src/ui/test/youtube_add_widget.dart';
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
  final songDataManager =
      SongDataManager(localDataManagerInstance: dataManagerInstance);
  GlobalKey<SongAddWidgetState> songAddKey = GlobalKey();
  List<SongModel> songs = [];

  final playlistDataManager =
      PlaylistDataManager(localDataManagerInstance: dataManagerInstance);
  GlobalKey<PlaylistAddWidgetState> playlistAddKey = GlobalKey();
  List<PlaylistModel> playlists = [];

  final manager = JustAudioManager();
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
            songAddKey.currentState?.insertSongToBeEdited(song);
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
          editCallback: () {
            playlistAddKey.currentState?.insertPlaylistToBeEdited(playlist);
          },
          deleteAllCallback: () {},
          playlist: playlist,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: [
              const SizedBox(
                width: 1280,
                height: 720,
              ),
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
                left: 400,
                child: PlaylistAddWidget(
                  key: playlistAddKey,
                  callback: () {
                    loadPlaylists();
                  },
                ),
              ),
              Positioned(
                top: 200,
                left: 400,
                child: SizedBox(
                  width: 500,
                  height: 300,
                  child: ListView(
                    children: playlistContainers,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 1000,
                child: YoutubeAddWidget(
                  callback: () {
                    loadSongs();
                    loadPlaylists();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
