import 'dart:io';

import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/test/song_container.dart';
import 'package:flutter/material.dart';

class PlaylistContainer extends StatefulWidget {
  final PlaylistModel playlist;
  final void Function() callback;
  const PlaylistContainer(
      {super.key, required this.playlist, required this.callback});

  @override
  State<PlaylistContainer> createState() => _PlaylistContainerState();
}

class _PlaylistContainerState extends State<PlaylistContainer> {
  final playlistDataManager = PlaylistDataManager();
  @override
  Widget build(BuildContext context) {
    List<SongContainer> songContainers = [];
    for (SongModel song in widget.playlist.songs) {
      songContainers.add(
        SongContainer(
          song: song,
          callback: () {
            //loadSongs();
          },
          editCallback: () {
            //songAddKey.currentState?.insertSongToBeAdded(song);
          },
        ),
      );
    }

    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 13);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200,
        width: 400,
        color: Colors.blueAccent,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: ImageParser.getImageProviderFromString(
                            widget.playlist.icon)),
                  ),
                ),
              ),
              Text(widget.playlist.title, style: headline1),
              ElevatedButton(
                onPressed: () {
                  playlistDataManager.deletePlaylist(widget.playlist);
                  widget.callback();
                },
                child: const Icon(Icons.delete),
              )
            ],
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: ListView(
              children: songContainers,
            ),
          )
        ]),
      ),
    );
  }
}
