// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  List<SongModel> songs = [];
  List<PlaylistModel> playlists = [];
  final songDataManager = SongDataManager();
  final manager = JustAudioManager();

  SongModel songToBeAdded =
      SongModel(id: 1, title: '', icon: '', url: '', path: '');

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void loadSongs() async {
    print('Song loading');
    songs = await songDataManager.loadAllSongs();
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
              SongAddWidget(
                callback: () {
                  loadSongs();
                },
              ),
              Positioned(
                top: 170,
                child: SizedBox(
                  width: 500,
                  height: 200,
                  child: Row(
                    children: songContainers,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class SongContainer extends StatefulWidget {
  final SongModel song;
  final void Function() callback;
  const SongContainer({
    Key? key,
    required this.song,
    required this.callback,
  }) : super(key: key);

  @override
  State<SongContainer> createState() => _SongContainerState();
}

class _SongContainerState extends State<SongContainer> {
  final audioManager = JustAudioManager();
  final songDataManager = SongDataManager();

  @override
  void initState() {
    super.initState();
    print(widget.song.title);
    audioManager.load(widget.song.url);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 22);
    return Container(
      width: 200,
      height: 200,
      color: Colors.blue,
      child: Column(children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(
                File(widget.song.icon),
              ),
            ),
          ),
        ),
        Text(
          widget.song.title,
          style: headline1,
        ),
        Flexible(
          child: Row(
            children: [
              //
              // Play
              //
              IconButton(
                onPressed: () {
                  audioManager.play();
                },
                icon: const Icon(Icons.play_arrow),
              ),
              //
              // Pause
              //
              IconButton(
                onPressed: () {
                  audioManager.pause();
                },
                icon: const Icon(Icons.pause),
              ),
              //
              // Remove
              //
              IconButton(
                onPressed: () {
                  audioManager.stop();
                  songDataManager.removeSong(widget.song);
                  widget.callback();
                },
                icon: const Icon(Icons.remove),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class SongAddWidget extends StatefulWidget {
  final void Function() callback;
  const SongAddWidget({super.key, required this.callback});

  @override
  State<SongAddWidget> createState() => _SongAddWidgetState();
}

class _SongAddWidgetState extends State<SongAddWidget> {
  final songDataManager = SongDataManager();
  SongModel songToBeAdded =
      SongModel(id: 1, title: '', icon: '', url: '', path: '');

  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 22);
    TextStyle blackHeadline1 = headline1.copyWith(color: Colors.black);
    TextStyle headline2 = headline1.copyWith(fontSize: 20);
    TextStyle blackHeadline2 = headline2.copyWith(color: Colors.black);

    return SizedBox(
      width: 800,
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Column(
              children: [
                //
                // Title TextField
                //
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          songToBeAdded.title = value.toString();
                        });
                      },
                      style: blackHeadline2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Title',
                      ),
                    ),
                  ),
                ),
                //
                // Link TextField
                //
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          songToBeAdded.url = value.toString();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          songToBeAdded.url = value.toString();
                        });
                      },
                      style: blackHeadline2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Link',
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      //
                      // Icon
                      //
                      Flexible(
                        child: Container(
                          width: 400,
                          height: 50,
                          alignment: Alignment.centerLeft,
                          color: Colors.white,
                          child: Text(
                            songToBeAdded.icon,
                            style: blackHeadline1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //
          // Add Song Button
          //
          Flexible(
            flex: 1,
            child: SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //
                  // Song
                  //
                  Container(
                    width: 150,
                    height: 50,
                    color: Colors.blue,
                    child: TextButton(
                      onPressed: () {
                        songDataManager.addSong(songToBeAdded);
                        widget.callback();
                      },
                      child: Text(
                        'Add Song',
                        style: headline2,
                      ),
                    ),
                  ),
                  //
                  // Reload
                  //
                  Container(
                    width: 150,
                    height: 50,
                    color: Colors.yellow,
                    child: TextButton(
                      onPressed: () async {
                        widget.callback();
                      },
                      child: Text(
                        'Reload Songs',
                        style: headline2,
                      ),
                    ),
                  ),
                  //
                  // Icon
                  //
                  Container(
                    width: 150,
                    height: 50,
                    color: Colors.red,
                    child: TextButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );

                        if (result != null) {
                          PlatformFile file = result.files.first;
                          setState(() {
                            songToBeAdded.icon = file.path!;
                          });
                        }
                      },
                      child: Text(
                        'Add Icon',
                        style: headline2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(children: [
              Text('Song to be Added', style: headline2),
              Text('Title: ${songToBeAdded.title}', style: headline2),
              Text('Icon: ${songToBeAdded.icon}', style: headline2),
              Text('Url: ${songToBeAdded.url}', style: headline2),
              Text('Path: ${songToBeAdded.path}', style: headline2),
            ]),
          )
        ],
      ),
    );
  }
}
