import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/test/song_container.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/material.dart';

class PlaylistContainer extends StatefulWidget {
  final PlaylistModel playlist;
  final void Function() callback;
  final void Function() editCallback;
  final void Function() deleteAllCallback;
  const PlaylistContainer({
    super.key,
    required this.playlist,
    required this.callback,
    required this.editCallback,
    required this.deleteAllCallback,
  });

  @override
  State<PlaylistContainer> createState() => _PlaylistContainerState();
}

class _PlaylistContainerState extends State<PlaylistContainer> {
  final playlistDataManager =
      PlaylistDataManager(localDataManagerInstance: dataManagerInstance);
  final songDataManager = SongDataManager(
      localDataManagerInstance: dataManagerInstance,
      downloadService: HttpDownloadService(filePath: FilePathImpl()));
  final justPlaylistManager = JustPlaylistManager();

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.amber),
      overlayColor: MaterialStateProperty.all(Colors.amber),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
    );

    List<SongContainer> songContainers = [];
    List<SongModel> songs = [];
    for (SongModel song in widget.playlist.songs) {
      songs.add(song);
      songContainers.add(
        SongContainer(
          song: song,
          callback: () {},
          editCallback: () {},
        ),
      );
    }

    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200,
        width: 400,
        color: Colors.blueAccent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
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
                  Flexible(
                      child: Text(widget.playlist.title, style: headline1)),
                  Flexible(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              playlistDataManager
                                  .deletePlaylist(widget.playlist);
                              widget.callback();
                            },
                            child: const Icon(Icons.delete),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: buttonStyle,
                            onPressed: () {
                              widget.editCallback();
                            },
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        ElevatedButton(
                          style: buttonStyle,
                          onPressed: () {
                            for (SongModel song in songs) {
                              songDataManager.removeSong(song);
                            }
                          },
                          child: Text('Delete All', style: headline1),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: buttonStyle,
                            onPressed: () async {
                              await justPlaylistManager
                                  .setPlaylist(widget.playlist);
                              justPlaylistManager.player.play();
                            },
                            child: const Icon(Icons.play_arrow),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ElevatedButton(
                            style: buttonStyle,
                            onPressed: () async {
                              justPlaylistManager.player.pause();
                            },
                            child: const Icon(Icons.pause),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              width: 200,
              child: ListView(
                children: songContainers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
