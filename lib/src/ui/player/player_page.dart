import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/contrast_check.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:bossa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localization/localization.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:io';

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
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _updatePlaylistFromController(PlaylistUIController controller) {
    final newPlaylist = controller.playlist;

    if (newPlaylist.songs.isNotEmpty &&
        newPlaylist.songs.length != playlist.songs.length) {
      playlist = newPlaylist;

      // Ensure currentIndex is within bounds of the new playlist
      if (currentIndex >= playlist.songs.length) {
        currentIndex = 0;
      }

      updatePalette(playlist.songs[0].icon);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    final playlistUIController = Modular.get<PlaylistUIController>();

    // Use a post-frame callback to ensure UI controller state is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updatePlaylistFromController(playlistUIController);
      }
    });

    // Also add a small delay as backup in case the post-frame callback is too early
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _updatePlaylistFromController(playlistUIController);
      }
    });

    final settingsController = Modular.get<SettingsController>();
    settingsController.addListener(() {
      gradient = settingsController.gradient;
      if (mounted) {
        setState(() {});
      }
    });

    playlistUIController.addListener(() {
      _updatePlaylistFromController(playlistUIController);
    });
  }

  Widget playerWidget({bool isHorizontal = false}) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentTheme.accentColor;
    final contrastColor = colorController.currentTheme.contrastColor;
    final contrastAccent = colorController.currentTheme.contrastAccent;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    final playlistManager = Modular.get<PlaylistAudioManager>();
    final songDataManager = Modular.get<SongDataManager>();
    final audioManager = Modular.get<AudioManager>();

    final titleStyle = GoogleFonts.poppins(
        color: contrastColor, fontSize: 15, fontWeight: FontWeight.bold);
    final authorStyle = GoogleFonts.poppins(
        color: contrastAccent, fontSize: 10, fontWeight: FontWeight.normal);

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );

    Stream<int?> songsStream = playlistManager.indexesStream();

    Stream<bool> playingStream = audioManager.playingStream();

    Stream<bool> shuffleStream = playlistManager.shuffleModeEnabledStream();

    Stream<PlayMode> playModeStream = playlistManager.playModeStream();

    final imageSize =
        size.width > size.height ? size.height * 0.75 : size.width;
    double imageWidth = imageSize - sliderSpacing * 2;

    double width = isHorizontal ? size.width / 2 : size.width;

    return StreamBuilder<int?>(
      stream: songsStream,
      builder: (context, snapshot) {
        if (playlist.songs.isEmpty) {
          if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final playlistUIController = Modular.get<PlaylistUIController>();
              _updatePlaylistFromController(playlistUIController);
            });

            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted && playlist.songs.isEmpty) {
                final playlistUIController =
                    Modular.get<PlaylistUIController>();
                _updatePlaylistFromController(playlistUIController);
              }
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.music,
                  size: 64,
                  color: contrastAccent,
                ),
                SizedBox(height: 16),
                Text(
                  snapshot.hasData
                      ? 'Loading playlist...'
                      : 'No songs in playlist',
                  style: TextStyle(color: contrastColor, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  snapshot.hasData
                      ? 'Please wait'
                      : 'Add some songs to start playing',
                  style: TextStyle(color: contrastAccent, fontSize: 14),
                ),
              ],
            ),
          );
        }

        SongModel currentSong = playlist.songs[0];
        int? state = snapshot.data;

        if (state != null && state >= 0 && state < playlist.songs.length) {
          currentSong = playlist.songs[state];

          if (state != currentIndex) {
            currentIndex = state;
            if (Platform.isLinux && currentSong.path.isEmpty) {
              // playlistManager.insert(currentIndex, currentSong.url);
              // Future.delayed(const Duration(seconds: 2)).then((value) {
              //   playlistManager.removeAt(currentIndex);
              // });
            }
            updatePalette(currentSong.icon);

            if (currentSong.id != -1) {
              currentSong.timesPlayed += 1;
              songDataManager.editSong(currentSong);
            }
          }
        } else if (state != null) {
          // Handle case where index is out of bounds
          print(
              'Warning: Audio manager index $state is out of bounds for playlist with ${playlist.songs.length} songs');

          // Clamp the index to valid bounds and use it
          int clampedIndex = state.clamp(0, playlist.songs.length - 1);
          if (playlist.songs.isNotEmpty) {
            currentSong = playlist.songs[clampedIndex];
            currentIndex = clampedIndex;
          }
        }

        final widgets = [
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
            mainAxisAlignment: isHorizontal
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: width,
                  child: TextStyles().getConstrainedTextByWidth(
                    textStyle: titleStyle,
                    text: currentSong.title,
                    textWidth: size.width,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: width,
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
                stream: audioManager.getDurationStream(),
                builder: (context, stream) {
                  double max = stream.data == null
                      ? 2
                      : stream.data!.inSeconds.toDouble();

                  return StreamBuilder<Duration>(
                    stream: audioManager.getPositionStream(),
                    builder: (context, snapshot) {
                      double value = snapshot.data == null
                          ? 1
                          : snapshot.data!.inSeconds.toDouble();
                      max = max > value ? max : value + 1;
                      String maxString = durationFormatter(
                        Duration(
                          seconds: max.toInt(),
                        ),
                      );

                      return Column(
                        children: [
                          SizedBox(
                            width: width,
                            child: SliderTheme(
                              data: SliderThemeData(
                                inactiveTrackColor: backgroundAccent,
                                activeTrackColor: contrastColor,
                                thumbColor: contrastColor,
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                                thumbShape: const RoundSliderThumbShape(
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
                                    currentIndex,
                                  );
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
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
                                ],
                              ),
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
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<bool>(
                          stream: shuffleStream,
                          builder: (context, snapshot) {
                            bool shuffle =
                                snapshot.data != null ? snapshot.data! : false;
                            return SizedBox(
                              width: iconSize * 1.5,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await playlistManager
                                      .setShuffleModeEnabled(!shuffle);
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
                                      color:
                                          shuffle ? accentColor : contrastColor,
                                    ),
                                    SizedBox(
                                      height: iconSize * 0.1,
                                    ),
                                    shuffle
                                        ? Container(
                                            height: iconSize * 0.25,
                                            width: iconSize * 0.5,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: accentColor,
                                            ),
                                          )
                                        : SizedBox(
                                            height: iconSize * 0.25,
                                          )
                                  ],
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        width: 3 * iconSize / 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            await playlistManager.seekToPrevious();
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
                            bool playing =
                                snapshot.data != null ? snapshot.data! : false;

                            return SizedBox(
                              width: 3 * iconSize / 2,
                              child: ElevatedButton(
                                onPressed: () async {
                                  playing
                                      ? await audioManager.pause()
                                      : await audioManager.play();
                                },
                                style: buttonStyle,
                                child: FaIcon(
                                  playing
                                      ? FontAwesomeIcons.solidCirclePause
                                      : FontAwesomeIcons.solidCirclePlay,
                                  size: iconSize * 1.5,
                                  color: contrastColor,
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        width: 3 * iconSize / 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            await playlistManager.seekToNext();
                          },
                          style: buttonStyle,
                          child: FaIcon(
                            FontAwesomeIcons.forwardStep,
                            size: iconSize,
                            color: contrastColor,
                          ),
                        ),
                      ),
                      StreamBuilder<PlayMode>(
                        stream: playModeStream,
                        builder: (context, snapshot) {
                          PlayMode loopMode = snapshot.data ?? PlayMode.single;

                          // Determine icon based on mode
                          List<List<dynamic>> iconData =
                              HugeIcons.strokeRoundedRepeatOne01;
                          if (loopMode == PlayMode.repeat) {
                            iconData = HugeIcons.strokeRoundedRepeatOne01;
                          }

                          // Determine color (active if not single/off)
                          bool isActive = loopMode != PlayMode.single;
                          Color iconColor =
                              isActive ? accentColor : contrastColor;

                          return SizedBox(
                            width: 3 * iconSize / 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                PlayMode nextMode;
                                switch (loopMode) {
                                  case PlayMode.loop:
                                    nextMode = PlayMode
                                        .repeat; // From loop all -> repeat one
                                    break;
                                  case PlayMode.repeat:
                                    nextMode = PlayMode
                                        .single; // From repeat one -> off
                                    break;
                                  case PlayMode.single:
                                  default:
                                    nextMode =
                                        PlayMode.loop; // From off -> loop all
                                    break;
                                }
                                await playlistManager.setPlayMode(nextMode);
                              },
                              style: buttonStyle,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: iconSize * 0.35,
                                  ),
                                  HugeIcon(
                                    icon: iconData,
                                    size: iconSize,
                                    color: iconColor,
                                  ),
                                  SizedBox(
                                    height: iconSize * 0.1,
                                  ),
                                  Container(
                                    height: iconSize * 0.25,
                                    width: iconSize * 0.5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isActive
                                          ? accentColor
                                          : Colors.transparent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: x / 2,
          )
        ];
        return isHorizontal
            ? Column(
                children: widgets,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets,
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );
    Color gradientColor = backgroundColor;
    if (palette != null && palette!.dominantColor != null) {
      gradientColor =
          gradient ? palette!.dominantColor!.color : backgroundColor;
    }

    bool isContrast =
        ContrastCheck().contrastCheck(gradientColor, contrastColor);
    final headerStyle = GoogleFonts.poppins(
      color: isContrast ? contrastColor : backgroundColor,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    );

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
                colors: [
                  gradientColor,
                  backgroundColor,
                ],
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
                            color: isContrast ? contrastColor : backgroundColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${"playing-now".i18n()}: \n ${playlist.title}',
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
                  Expanded(
                    child: playerWidget(
                      isHorizontal: size.width > size.height,
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
