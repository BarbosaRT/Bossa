import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  final PlaylistModel playlist;
  const PlayerPage({super.key, required this.playlist});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static double x = 30.0;
  double iconSize = 30;
  final JustPlaylistManager playlistManager = JustPlaylistManager();

  @override
  void initState() {
    super.initState();
    playlistManager.setPlaylist(widget.playlist);
  }

  String durationFormatter(Duration duration, {int length = 0}) {
    String durationString = duration.toString().split('.')[0];
    String replacement = zerosBeforeDuration(duration);
    String replacedString = durationString.replaceFirst(replacement, '');

    if (length > replacedString.length) {
      replacement = '';
      durationString = duration.toString().split('.')[0];
      int diference = durationString.length - length;
      for (var number in durationString.split('')) {
        if (number != '0' && number != ':' || diference == 0) {
          break;
        }
        replacement += number;
        diference -= 1;
      }
    }

    return durationString.replaceFirst(replacement, '');
  }

  String zerosBeforeDuration(Duration duration) {
    String d = duration.toString().split('.')[0];
    String replacement = '';
    for (var number in d.split('')) {
      if (number != '0' && number != ':') {
        break;
      }
      replacement += number;
    }
    return replacement;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final contrastAccent = colorController.currentScheme.contrastAccent;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final headerStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 14, fontWeight: FontWeight.normal);
    final titleStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 15, fontWeight: FontWeight.bold);
    final authorStyle = GoogleFonts.poppins(
        color: contrastAccent, fontSize: 10, fontWeight: FontWeight.normal);

    String title = '''Tocando Agora: \n ${widget.playlist.title}''';

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    Stream<SequenceState?> songsStream =
        playlistManager.player.sequenceStateStream;

    AudioPlayer audioManager = playlistManager.player;

    double sliderSpacing = 7;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: x - sliderSpacing),
          child: Column(
            children: [
              SizedBox(
                height: x / 2,
              ),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.angleDown,
                    size: iconSize,
                    color: contrastColor,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: x,
              ),
              StreamBuilder<SequenceState?>(
                stream: songsStream,
                builder: (context, snapshot) {
                  String icon = widget.playlist.icon;
                  SongModel currentSong = widget.playlist.songs[0];
                  SequenceState? state = snapshot.data;
                  if (state != null) {
                    currentSong = widget.playlist.songs[state.currentIndex];
                    icon = widget.playlist.songs[state.currentIndex].icon;
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: sliderSpacing),
                        child: SizedBox(
                          width: size.width - sliderSpacing * 2,
                          height: size.width - x - sliderSpacing * 2,
                          child: Image(
                            image: ImageParser.getImageProviderFromString(
                              icon,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: sliderSpacing),
                            child: SizedBox(
                              width: size.width,
                              child: Text(
                                currentSong.title,
                                style: titleStyle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: sliderSpacing),
                            child: SizedBox(
                              width: size.width,
                              child: Text(
                                currentSong.author,
                                style: authorStyle,
                              ),
                            ),
                          ),
                          //
                          // Slider
                          //
                          StreamBuilder<Duration?>(
                            stream: audioManager.durationStream,
                            builder: (context, stream) {
                              double max = stream.data == null
                                  ? 2
                                  : stream.data!.inSeconds.toDouble();
                              max = max > 0 ? max : 1;
                              return StreamBuilder<Duration>(
                                stream: audioManager.positionStream,
                                builder: (context, snapshot) {
                                  double value = snapshot.data == null
                                      ? 1
                                      : snapshot.data!.inSeconds.toDouble();

                                  String maxString = durationFormatter(
                                    Duration(
                                      seconds: max.toInt(),
                                    ),
                                  );

                                  return Column(
                                    children: [
                                      SliderTheme(
                                        data: SliderThemeData(
                                          inactiveTrackColor: backgroundAccent,
                                          activeTrackColor: contrastColor,
                                          thumbColor: contrastColor,
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                            overlayRadius: 0,
                                          ),
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius: 7),
                                        ),
                                        child: Slider(
                                          min: 0,
                                          max: max,
                                          value: value,
                                          label: durationFormatter(
                                            Duration(
                                              seconds: value.toInt(),
                                            ),
                                          ),
                                          divisions: max.toInt(),
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                audioManager.seek(
                                                  Duration(
                                                    seconds: value.toInt(),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: sliderSpacing),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                durationFormatter(
                                                  Duration(
                                                    seconds: value.toInt(),
                                                  ),
                                                  length: maxString.length,
                                                ),
                                                style: titleStyle,
                                              ),
                                              Text(
                                                maxString,
                                                style: titleStyle,
                                              )
                                            ]),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: sliderSpacing),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      playlistManager
                                          .setShuffleModeEnabled(true);
                                    },
                                    style: buttonStyle,
                                    child: FaIcon(
                                      FontAwesomeIcons.shuffle,
                                      size: iconSize,
                                      color: contrastColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      playlistManager.seekToPrevious();
                                    },
                                    style: buttonStyle,
                                    child: FaIcon(
                                      FontAwesomeIcons.backwardStep,
                                      size: iconSize,
                                      color: contrastColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      audioManager.playing
                                          ? audioManager.pause()
                                          : audioManager.play();
                                    },
                                    style: buttonStyle,
                                    child: FaIcon(
                                      audioManager.playing
                                          ? FontAwesomeIcons.solidCirclePause
                                          : FontAwesomeIcons.solidCirclePlay,
                                      size: iconSize * 1.5,
                                      color: contrastColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      playlistManager.seekToNext();
                                    },
                                    style: buttonStyle,
                                    child: FaIcon(
                                      FontAwesomeIcons.forwardStep,
                                      size: iconSize,
                                      color: contrastColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 3 * iconSize / 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      playlistManager.setLoopMode(LoopMode.one);
                                    },
                                    style: buttonStyle,
                                    child: FaIcon(
                                      FontAwesomeIcons.repeat,
                                      size: iconSize,
                                      color: contrastColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
