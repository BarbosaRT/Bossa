import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/material.dart';

class SongContainer extends StatefulWidget {
  final SongModel song;
  final void Function() callback;
  final void Function() editCallback;
  const SongContainer({
    Key? key,
    required this.song,
    required this.callback,
    required this.editCallback,
  }) : super(key: key);

  @override
  State<SongContainer> createState() => _SongContainerState();
}

class _SongContainerState extends State<SongContainer> {
  final audioManager = audioManagerInstance;
  final songDataManager = SongDataManager(
      localDataManagerInstance: dataManagerInstance,
      downloadService: HttpDownloadService(filePath: FilePathImpl()));

  @override
  void initState() {
    super.initState();
  }

  String durationFormatter(Duration duration) {
    String d = duration.toString().split('.')[0];
    if (duration.inHours <= 0) {
      d = d.replaceFirst('0:', '');
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headline1 = const TextStyle(color: Colors.white, fontSize: 13);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: 250,
        height: 200,
        color: const Color.fromARGB(255, 0, 60, 163),
        child: Column(
          children: [
            Text(
              widget.song.title,
              style: headline1,
            ),
            SizedBox(
              width: 200,
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: ImageParser.getImageProviderFromString(
                            widget.song.icon),
                      ),
                    ),
                  ),
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        //
                        // Play
                        //
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              String path = widget.song.path.isEmpty
                                  ? widget.song.url
                                  : widget.song.path;
                              audioManager.load(path);
                              audioManager.play();
                            },
                            child: const Icon(Icons.play_arrow),
                          ),
                        ),
                        //
                        // Pause
                        //
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              audioManager.pause();
                            },
                            child: const Icon(Icons.pause),
                          ),
                        ),
                        //
                        // Edit
                        //
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              audioManager.stop();
                              widget.editCallback();
                            },
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        //
                        // Delete
                        //
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              audioManager.stop();
                              songDataManager.removeSong(widget.song);
                              widget.callback();
                            },
                            child: const Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              child: StreamBuilder<Duration?>(
                stream: audioManager.getDurationStream(),
                builder: (context, stream) {
                  double max = stream.data == null
                      ? 2
                      : stream.data!.inSeconds.toDouble();
                  max = max > 0 ? max : 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: StreamBuilder<Duration>(
                            stream: audioManager.getPositionStream(),
                            builder: (context, snapshot) {
                              double value = snapshot.data == null
                                  ? 1
                                  : snapshot.data!.inSeconds.toDouble();
                              return SliderTheme(
                                data: const SliderThemeData(
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 0),
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 7)),
                                child: Slider(
                                  min: 0,
                                  max: max,
                                  value: value,
                                  label: durationFormatter(
                                      Duration(seconds: value.toInt())),
                                  divisions: max.toInt(),
                                  onChanged: (value) {
                                    setState(() {
                                      audioManager.seek(
                                          Duration(seconds: value.toInt()));
                                    });
                                  },
                                ),
                              );
                            }),
                      ),
                      Text(
                        durationFormatter(Duration(seconds: max.toInt())),
                        style: headline1,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
