import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/contrast_check.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:text_scroll/text_scroll.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  bool gradient = true;
  PaletteGenerator? palette;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    final settingsController = Modular.get<SettingsController>();
    gradient = settingsController.gradient;
    settingsController.addListener(() {
      gradient = settingsController.gradient;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> updatePalette(String image) async {
    palette = await PaletteGenerator.fromImageProvider(
      ImageParser.getImageProviderFromString(image),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playlistManager = Modular.get<JustPlaylistManager>();
    final audioManager = playlistManager.player;
    final playlistUIController = Modular.get<PlaylistUIController>();

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    final colorController = Modular.get<ColorController>();
    final contrastAccent = colorController.currentTheme.contrastAccent;
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    Stream<bool> playingStream = playlistManager.player.playingStream;
    Stream<SequenceState?> songsStream =
        playlistManager.player.sequenceStateStream;

    return StreamBuilder<bool>(
      stream: playingStream,
      builder: (context, snapshot) {
        bool playing = snapshot.data != null ? snapshot.data! : false;
        return playlistUIController.hasPlayedOnce
            ? StreamBuilder<SequenceState?>(
                stream: songsStream,
                builder: (context, snapshot) {
                  SongModel currentSong =
                      playlistUIController.playlist.songs[0];
                  SequenceState? state = snapshot.data;

                  bool isHorizontal = size.width > size.height;
                  Color gradientColor = backgroundAccent;
                  if (palette != null) {
                    gradientColor = gradient
                        ? palette!.dominantColor!.color
                        : gradientColor;
                  }

                  final color = gradientColor;

                  Color finalContrastColor = contrastColor;
                  Color finalContrastAccent = contrastAccent;
                  if (!ContrastCheck()
                      .contrastCheck(finalContrastColor, gradientColor)) {
                    finalContrastColor = backgroundColor;
                    finalContrastAccent = backgroundAccent;
                  }
                  final titleStyle = TextStyles()
                      .boldHeadline2
                      .copyWith(color: finalContrastColor);
                  final authorStyle = TextStyles()
                      .headline3
                      .copyWith(color: finalContrastAccent);

                  if (state != null) {
                    currentSong =
                        playlistUIController.playlist.songs[state.currentIndex];
                    if (state.currentIndex != currentIndex) {
                      currentIndex = state.currentIndex;
                      updatePalette(currentSong.icon);
                    }
                  }

                  final widgets = [
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image(
                            image: ImageParser.getImageProviderFromString(
                              currentSong.icon,
                            ),
                            fit: BoxFit.cover,
                            alignment: FractionalOffset.center,
                            width: 60,
                            height: 60,
                          ),
                        ),
                        SizedBox(
                          width: x / 4,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: isHorizontal
                                    ? size.width * UIConsts.leftBarRatio - x * 2
                                    : size.width - x * 8 - 5,
                                height: 20,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: (isHorizontal
                                              ? size.width *
                                                      UIConsts.leftBarRatio -
                                                  x * 2
                                              : size.width - x * 8) -
                                          10,
                                      child: TextScroll(
                                        currentSong.title,
                                        style: titleStyle,
                                        mode: TextScrollMode.endless,
                                        velocity: const Velocity(
                                            pixelsPerSecond: Offset(100, 0)),
                                        delayBefore: const Duration(seconds: 5),
                                        pauseBetween:
                                            const Duration(seconds: 5),
                                        textAlign: TextAlign.right,
                                        selectable: false,
                                        intervalSpaces: 20,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          stops: const [0.75, 1],
                                          colors: [color.withOpacity(0), color],
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            Text(
                              currentSong.author,
                              style: authorStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                              color: finalContrastColor,
                            ),
                          ),
                        ),
                        isHorizontal
                            ? const Spacer()
                            : SizedBox(
                                width: x / 2,
                              ),
                        SizedBox(
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
                                  ? FontAwesomeIcons.solidCirclePause
                                  : FontAwesomeIcons.solidCirclePlay,
                              size: iconSize * 1.5,
                              color: finalContrastColor,
                            ),
                          ),
                        ),
                        isHorizontal
                            ? const Spacer()
                            : SizedBox(
                                width: x / 2,
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
                              color: finalContrastColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  ];
                  return GestureDetector(
                    onTap: () {
                      Modular.to.pop();
                    },
                    onLongPress: () {
                      audioManager.pause();
                      if (mounted) {
                        setState(() {
                          playlistUIController.setHasPlayedOnce(false);
                        });
                      }
                    },
                    child: Container(
                      height: isHorizontal ? 120 : 60,
                      width: isHorizontal
                          ? size.width * UIConsts.leftBarRatio
                          : size.width - x / 2,
                      decoration: BoxDecoration(
                        borderRadius:
                            isHorizontal ? null : BorderRadius.circular(15),
                        color: gradientColor,
                        // gradient: gradient
                        //     ? LinearGradient(
                        //         colors: [
                        //           gradientColor.withOpacity(0.2),
                        //           gradientColor.withOpacity(0)
                        //         ],
                        //       )
                        //     : null,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: isHorizontal ? 0 : x / 2),
                        child: isHorizontal
                            ? Column(
                                children: widgets,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: widgets),
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }
}
