import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:text_scroll/text_scroll.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  final double sliderSpacing = 7;
  int currentIndex = 0;
  bool gradient = true;

  PlaylistModel playlist =
      PlaylistModel(id: 0, title: 'title', icon: 'icon', songs: []);

  PaletteGenerator? palette;

  void updatePalette(String image) async {
    palette = await PaletteGenerator.fromImageProvider(
      ImageParser.getImageProviderFromString(image),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    final playlistUIController = Modular.get<PlaylistUIController>();
    playlist =
        PlaylistModel.fromMap(playlistUIController.currentPlaylist.toMap());

    final playlistManager = Modular.get<JustPlaylistManager>();
    playlistManager.setPlaylist(playlist);

    updatePalette(playlist.songs[0].icon);

    final settingsController = Modular.get<SettingsController>();
    settingsController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          gradient = settingsController.gradientOnPlayer;
        });
      });
    });
    playlistUIController.addListener(() async {
      playlist = playlistUIController.playlist;
      playlistManager.setPlaylist(playlist);
      updatePalette(playlist.songs[0].icon);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  String durationFormatter(Duration duration, {int length = 4}) {
    length = length < 4 ? 4 : length;

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
    final accentColor = colorController.currentScheme.accentColor;
    final contrastColor = colorController.currentScheme.contrastColor;
    final contrastAccent = colorController.currentScheme.contrastAccent;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final playlistManager = Modular.get<JustPlaylistManager>();
    final songDataManager = Modular.get<SongDataManager>();

    final headerStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 14, fontWeight: FontWeight.normal);
    final titleStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 15, fontWeight: FontWeight.bold);
    final authorStyle = GoogleFonts.poppins(
        color: contrastAccent, fontSize: 10, fontWeight: FontWeight.normal);

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    Stream<SequenceState?> songsStream =
        playlistManager.player.sequenceStateStream;

    Stream<bool> playingStream = playlistManager.player.playingStream;

    Stream<bool> shuffleStream =
        playlistManager.player.shuffleModeEnabledStream;

    Stream<LoopMode> loopmodeStream = playlistManager.player.loopModeStream;

    AudioPlayer audioManager = playlistManager.player;

    Color gradientColor = backgroundColor;
    if (palette != null) {
      gradientColor =
          gradient ? palette!.dominantColor!.color : backgroundColor;
    }

    final imageSize =
        size.width > size.height ? size.height * 0.75 : size.width;
    double imageWidth = imageSize - sliderSpacing * 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradientColor, backgroundColor],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: x - sliderSpacing),
              child: Column(
                children: [
                  SizedBox(
                    height: x / 2,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: iconSize * 1.5,
                        height: iconSize * 1.5,
                        child: ElevatedButton(
                          style: buttonStyle,
                          onPressed: () {
                            Modular.to.pushNamed('/');
                          },
                          child: FaIcon(
                            FontAwesomeIcons.angleDown,
                            size: iconSize,
                            color: contrastColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Tocando Agora: \n ${playlist.title}',
                            style: headerStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: iconSize * 1.5,
                        height: iconSize * 1.5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: x,
                  ),
                  Expanded(
                    child: StreamBuilder<SequenceState?>(
                      stream: songsStream,
                      builder: (context, snapshot) {
                        SongModel currentSong = playlist.songs[0];
                        SequenceState? state = snapshot.data;
                        if (state != null) {
                          currentSong = playlist.songs[state.currentIndex];

                          if (state.currentIndex != currentIndex) {
                            currentIndex = state.currentIndex;
                            updatePalette(currentSong.icon);

                            if (currentSong.id != -1) {
                              currentSong.timesPlayed += 1;
                              songDataManager.editSong(currentSong);
                            }
                          }
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: sliderSpacing),
                              child: Image(
                                image: ImageParser.getImageProviderFromString(
                                  currentSong.icon,
                                ),
                                fit: BoxFit.cover,
                                alignment: FractionalOffset.center,
                                width: imageWidth,
                                height: imageWidth - x,
                              ),
                            ),
                            SizedBox(
                              height: x,
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: sliderSpacing),
                                  child: SizedBox(
                                    width: size.width,
                                    child: TextScroll(
                                      currentSong.title,
                                      mode: TextScrollMode.endless,
                                      velocity: const Velocity(
                                          pixelsPerSecond: Offset(100, 0)),
                                      delayBefore: const Duration(seconds: 10),
                                      pauseBetween: const Duration(seconds: 5),
                                      style: titleStyle,
                                      textAlign: TextAlign.right,
                                      selectable: true,
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

                                    return StreamBuilder<Duration>(
                                      stream: audioManager.positionStream,
                                      builder: (context, snapshot) {
                                        double value = snapshot.data == null
                                            ? 1
                                            : snapshot.data!.inSeconds
                                                .toDouble();
                                        max = max > value ? max : value + 1;
                                        String maxString = durationFormatter(
                                          Duration(
                                            seconds: max.toInt(),
                                          ),
                                        );

                                        return Column(
                                          children: [
                                            SliderTheme(
                                              data: SliderThemeData(
                                                inactiveTrackColor:
                                                    backgroundAccent,
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
                                                  length: maxString.length,
                                                ),
                                                divisions: max.toInt(),
                                                onChanged: (value) async {
                                                  await playlistManager.seek(
                                                      Duration(
                                                        seconds: value.toInt(),
                                                      ),
                                                      currentIndex);
                                                  setState(
                                                    () {},
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: sliderSpacing),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                //
                                // Player
                                //
                                Padding(
                                  padding: EdgeInsets.only(left: sliderSpacing),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StreamBuilder<bool>(
                                          stream: shuffleStream,
                                          builder: (context, snapshot) {
                                            bool shuffle = snapshot.data != null
                                                ? snapshot.data!
                                                : false;
                                            return SizedBox(
                                              width: iconSize * 1.5,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  playlistManager
                                                      .setShuffleModeEnabled(
                                                          !shuffle);
                                                },
                                                style: buttonStyle,
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: iconSize * 0.35,
                                                    ),
                                                    FaIcon(
                                                      FontAwesomeIcons.shuffle,
                                                      size: iconSize,
                                                      color: shuffle
                                                          ? accentColor
                                                          : contrastColor,
                                                    ),
                                                    SizedBox(
                                                      height: iconSize * 0.1,
                                                    ),
                                                    shuffle
                                                        ? Container(
                                                            height:
                                                                iconSize * 0.25,
                                                            width:
                                                                iconSize * 0.5,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              color:
                                                                  accentColor,
                                                            ),
                                                          )
                                                        : SizedBox(
                                                            height:
                                                                iconSize * 0.25,
                                                          )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
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
                                      StreamBuilder<bool>(
                                          stream: playingStream,
                                          builder: (context, snapshot) {
                                            bool playing = snapshot.data != null
                                                ? snapshot.data!
                                                : false;

                                            return SizedBox(
                                              width: 3 * iconSize / 2,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  playing
                                                      ? audioManager.pause()
                                                      : audioManager.play();
                                                },
                                                style: buttonStyle,
                                                child: FaIcon(
                                                  playing
                                                      ? FontAwesomeIcons
                                                          .solidCirclePause
                                                      : FontAwesomeIcons
                                                          .solidCirclePlay,
                                                  size: iconSize * 1.5,
                                                  color: contrastColor,
                                                ),
                                              ),
                                            );
                                          }),
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
                                      StreamBuilder<LoopMode>(
                                        stream: loopmodeStream,
                                        builder: (context, snapshot) {
                                          LoopMode loopMode =
                                              snapshot.data != null
                                                  ? snapshot.data!
                                                  : LoopMode.all;

                                          bool isRepeating =
                                              loopMode == LoopMode.one;

                                          return SizedBox(
                                            width: 3 * iconSize / 2,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                playlistManager.setLoopMode(
                                                  isRepeating
                                                      ? LoopMode.all
                                                      : LoopMode.one,
                                                );
                                              },
                                              style: buttonStyle,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: iconSize * 0.35,
                                                  ),
                                                  FaIcon(
                                                    FontAwesomeIcons.repeat,
                                                    size: iconSize,
                                                    color: isRepeating
                                                        ? accentColor
                                                        : contrastColor,
                                                  ),
                                                  SizedBox(
                                                    height: iconSize * 0.1,
                                                  ),
                                                  isRepeating
                                                      ? Container(
                                                          height:
                                                              iconSize * 0.25,
                                                          width: iconSize * 0.5,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: accentColor,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height:
                                                              iconSize * 0.25,
                                                        )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: x / 2,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}