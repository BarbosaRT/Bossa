import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/youtube_to_playlist.dart';
import 'package:flutter/material.dart';

class YoutubeAddWidget extends StatefulWidget {
  final void Function() callback;
  const YoutubeAddWidget({super.key, required this.callback});

  @override
  State<YoutubeAddWidget> createState() => _YoutubeAddWidgetState();
}

class _YoutubeAddWidgetState extends State<YoutubeAddWidget> {
  final TextEditingController textEditingController = TextEditingController();
  final YoutubeToPlaylist youtubeToPlaylist = YoutubeToPlaylist();
  final PlaylistDataManager playlistDataManager = PlaylistDataManager();
  String url = '';
  bool added = false;

  @override
  Widget build(BuildContext context) {
    TextStyle blackHeadline1 =
        const TextStyle(color: Colors.black, fontSize: 13);

    return Container(
      width: 300,
      height: 100,
      color: Colors.greenAccent,
      child: Column(
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: textEditingController,
                    onChanged: (value) {
                      setState(() {
                        url = value.toString();
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        url = value.toString();
                      });
                    },
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        added = true;
                      });

                      PlaylistModel playlist =
                          await youtubeToPlaylist.convertYoutubePlaylist(url);
                      playlistDataManager.addPlaylist(playlist);
                      widget.callback();

                      Future.delayed(const Duration(seconds: 10)).then(
                        (value) {
                          setState(() {
                            added = false;
                          });
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
                added
                    ? const Icon(Icons.check, size: 50, color: Colors.white)
                    : const Icon(Icons.refresh, size: 50, color: Colors.white)
              ],
            ),
          ),
          Flexible(
            child: Container(
              width: 400,
              height: 50,
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: Text(
                'Playlist to be added url: $url',
                style: blackHeadline1,
              ),
            ),
          )
        ],
      ),
    );
  }
}
