import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SongAddWidget extends StatefulWidget {
  final void Function() callback;
  const SongAddWidget({
    super.key,
    required this.callback,
  });

  @override
  State<SongAddWidget> createState() => SongAddWidgetState();
}

class SongAddWidgetState extends State<SongAddWidget> {
  final songDataManager = SongDataManager(
    localDataManagerInstance: dataManagerInstance,
    downloadService: DioDownloadService(
      filePath: FilePathImpl(),
    ),
  );
  bool songAdded = false;
  bool editing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  SongModel songToBeAdded =
      SongModel(id: 1, title: '', icon: '', url: '', path: '');

  void insertSongToBeEdited(SongModel song) {
    songToBeAdded = SongModel.fromMap(song.toMap());
    _titleController.text = songToBeAdded.title;
    _linkController.text = songToBeAdded.url;
    setState(() {
      editing = true;
    });
  }

  @override
  void initState() {
    songAdded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 13);
    TextStyle blackHeadline1 = headline1.copyWith(color: Colors.black);

    return SizedBox(
      width: 400,
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
                          songToBeAdded.title = value.toString();
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
                // Link TextField
                //
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      controller: _linkController,
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
                      style: blackHeadline1,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Link',
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 400,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: Text(
                      songToBeAdded.path,
                      style: blackHeadline1,
                    ),
                  ),
                ),
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
                    height: 40,
                    color: Colors.blue,
                    child: TextButton(
                      onPressed: () async {
                        songAdded = true;
                        songToBeAdded = await SongParser()
                            .parseSongBeforeSave(songToBeAdded);
                        editing
                            ? songDataManager.editSong(songToBeAdded)
                            : songDataManager.addSong(songToBeAdded);
                        editing = false;
                        Future.delayed(const Duration(seconds: 1))
                            .then((value) {
                          setState(() {
                            songAdded = false;
                          });
                        });
                        widget.callback();
                      },
                      child: Text(
                        editing ? 'Update Song' : 'Add Song',
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
                      onPressed: () async {
                        widget.callback();
                      },
                      child: Text(
                        'Reload Songs',
                        style: headline1,
                      ),
                    ),
                  ),
                  //
                  // Path
                  //
                  Container(
                    width: 150,
                    height: 40,
                    color: Colors.orange,
                    child: TextButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                              'mp4',
                              'mp3',
                              'flac',
                              'wav',
                              'm4a'
                            ]);

                        if (result != null) {
                          PlatformFile file = result.files.first;
                          setState(() {
                            songToBeAdded.path = file.path!;
                          });
                        }
                      },
                      child: Text(
                        'Add Path',
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
                            songToBeAdded.icon = file.path!;
                          });
                        }
                      },
                      child: Text(
                        'Add Icon',
                        style: headline1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: ListView(children: [
              Text('Song to be Added', style: headline1),
              Text('Title: ${songToBeAdded.title}', style: headline1),
              Text('Icon: ${songToBeAdded.icon}', style: headline1),
              Text('Url: ${songToBeAdded.url}', style: headline1),
              Text('Path: ${songToBeAdded.path}', style: headline1),
              songAdded ? Text('Song added', style: headline1) : Container(),
            ]),
          )
        ],
      ),
    );
  }
}
