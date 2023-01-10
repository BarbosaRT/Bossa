import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PlaylistSongContainer extends StatefulWidget {
  final SongModel song;
  final void Function() removeSong;
  const PlaylistSongContainer(
      {super.key, required this.song, required this.removeSong});

  @override
  State<PlaylistSongContainer> createState() => _PlaylistSongContainerState();
}

class _PlaylistSongContainerState extends State<PlaylistSongContainer> {
  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 13);

    return Container(
      width: 300,
      height: 40,
      color: Colors.deepOrange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.song.title, style: headline1),
          ElevatedButton(
              onPressed: () {
                widget.removeSong();
              },
              child: const Icon(Icons.delete))
        ],
      ),
    );
  }
}

class PlaylistAddWidget extends StatefulWidget {
  final void Function() callback;
  const PlaylistAddWidget({
    super.key,
    required this.callback,
  });

  @override
  State<PlaylistAddWidget> createState() => PlaylistAddWidgetState();
}

class PlaylistAddWidgetState extends State<PlaylistAddWidget> {
  final playlistDataManager =
      PlaylistDataManager(localDataManagerInstance: dataManagerInstance);
  final songDataManager = SongDataManager(
      localDataManagerInstance: dataManagerInstance,
      downloadService: DioDownloadService(filePath: FilePathImpl()));
  List<SongModel> songs = [];

  bool playlistAdded = false;
  bool editing = false;
  final TextEditingController _titleController = TextEditingController();

  SongModel? selectedSong;

  PlaylistModel playlistToBeAdded =
      PlaylistModel(id: 0, title: 'title', icon: '', songs: []);

  void insertPlaylistToBeEdited(PlaylistModel playlist) {
    playlistToBeAdded = playlist;
    _titleController.text = playlistToBeAdded.title;
    setState(() {
      editing = true;
    });
  }

  void loadSongs() async {
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  @override
  void initState() {
    playlistAdded = false;
    super.initState();
    loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 13);
    TextStyle blackHeadline2 =
        const TextStyle(color: Colors.black, fontSize: 8);
    TextStyle blackHeadline1 = headline1.copyWith(color: Colors.black);

    List<DropdownMenuItem<SongModel>> dropdownList = [];
    for (SongModel song in songs) {
      String title = song.title;
      if (title.length > 35) {
        title = '${title.substring(0, 35)}...';
      }

      dropdownList.add(
        DropdownMenuItem<SongModel>(
          value: song,
          child: Text(
            title,
            style: headline1,
          ),
        ),
      );
    }

    List<String> songsTitles = [];
    List<PlaylistSongContainer> songsInPlaylist = [];
    for (SongModel song in playlistToBeAdded.songs) {
      String title = song.title;
      if (title.length > 35) {
        title = '${title.substring(0, 35)}...';
      }
      song.title = title;

      songsTitles.add(title);
      songsInPlaylist.add(
        PlaylistSongContainer(
          song: song,
          removeSong: () {
            setState(() {
              playlistToBeAdded.songs.remove(song);
            });
          },
        ),
      );
    }

    return SizedBox(
      width: 600,
      height: 160,
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
                      controller: _titleController,
                      onChanged: (value) {
                        setState(() {
                          playlistToBeAdded.title = value.toString();
                        });
                      },
                      style: blackHeadline1,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Title',
                      ),
                    ),
                  ),
                ),
                //
                // Icon
                //
                Flexible(
                  child: Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: Text(
                      playlistToBeAdded.icon,
                      style: blackHeadline1,
                    ),
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      DropdownButton<SongModel>(
                        value: selectedSong,
                        style: blackHeadline2,
                        dropdownColor: Colors.amber,
                        onChanged: (value) {
                          setState(() {
                            selectedSong = value;
                          });
                        },
                        items: dropdownList,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSong == null) return;
                          setState(() {
                            playlistToBeAdded.songs.add(selectedSong!);
                          });
                        },
                        child: const Icon(Icons.add),
                      )
                    ],
                  ),
                ),
                //
                // SongsInPlaylist
                //
                Flexible(
                  flex: 2,
                  child: ListView(children: songsInPlaylist),
                ),
              ],
            ),
          ),
          //
          // Add Playlist Button
          //
          Flexible(
            flex: 1,
            child: SizedBox(
              width: 100,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //
                  // Song
                  //
                  Container(
                    width: 150,
                    height: 40,
                    color: Colors.blue,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          playlistAdded = true;
                        });
                        editing
                            ? playlistDataManager
                                .editPlaylist(playlistToBeAdded)
                            : playlistDataManager
                                .addPlaylist(playlistToBeAdded);
                        editing = false;
                        Future.delayed(const Duration(seconds: 1))
                            .then((value) {
                          setState(() {
                            playlistAdded = false;
                          });
                        });
                        widget.callback();
                      },
                      child: Text(
                        editing ? 'Update Playlist' : 'Add Playlist',
                        style: headline1,
                      ),
                    ),
                  ),
                  //
                  // Icon
                  //
                  Container(
                    width: 150,
                    height: 40,
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
                            playlistToBeAdded.icon = file.path!;
                          });
                        }
                      },
                      child: Text(
                        'Add Icon',
                        style: headline1,
                      ),
                    ),
                  ),
                  //
                  // Reload
                  //
                  Container(
                    width: 150,
                    height: 40,
                    color: Colors.yellow,
                    child: TextButton(
                      onPressed: () {
                        widget.callback();
                      },
                      child: Text(
                        'Reload Playlists',
                        style: blackHeadline1,
                      ),
                    ),
                  ),
                  //
                  // Reload Songs
                  //
                  Container(
                    width: 150,
                    height: 40,
                    color: Colors.purple,
                    child: TextButton(
                      onPressed: () {
                        loadSongs();
                      },
                      child: Text(
                        'Reload Songs In Playlist Dropdown',
                        style: headline1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: SizedBox(
              height: 120,
              child: ListView(children: [
                Text('Playlist to be Added', style: headline1),
                Text('Title: ${playlistToBeAdded.title}', style: headline1),
                Text('Icon: ${playlistToBeAdded.icon}', style: headline1),
                Text('Songs: $songsTitles', style: headline1),
                playlistAdded
                    ? Text('Playlist added', style: headline1)
                    : Container(),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
