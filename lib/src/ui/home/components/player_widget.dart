import 'dart:async';
import 'package:bossa/utils/utils.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/audio_manager.dart';
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
  int currentIndex = -69;

  StreamSubscription<int?>? _indexSubscription;
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
    final playlistManager = Modular.get<PlaylistAudioManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    _indexSubscription = playlistManager.indexesStream().listen((int? state) {
      // This code now runs *outside* of a build cycle
      if (state != null && state != currentIndex) {
        currentIndex = state;

        // Get the song and update the palette
        final currentSong = playlistUIController.playlist.songs[state];
        updatePalette(currentSong.icon);
      }
    });
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
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

  Widget buildTitleWithFade(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    // Measure how wide the text actually is
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    final textFits = textPainter.width <= maxWidth;

    // Build the actual text widget (scrolling or static)
    final textWidget = textFits
        ? Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          )
        : TextScroll(
            text,
            style: style,
            mode: TextScrollMode.bouncing,
            velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
            delayBefore: const Duration(seconds: 3),
            pauseBetween: const Duration(seconds: 3),
            textAlign: TextAlign.left,
            selectable: false,
          );

    // 👇 Apply gradient fade only if text does NOT fit
    if (textFits) {
      return textWidget;
    } else {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.8, 1.0],
            colors: [Colors.white, Colors.transparent],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: textWidget,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playlistManager = Modular.get<PlaylistAudioManager>();
    final audioManager = Modular.get<AudioManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(Colors.transparent),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    );

    final colorController = Modular.get<ColorController>();
    final contrastAccent = colorController.currentTheme.contrastAccent;
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final backgroundColor = colorController.currentTheme.backgroundColor;

    Stream<bool> playingStream = audioManager.playingStream();
    Stream<int?> songsStream = playlistManager.indexesStream();

    return StreamBuilder<bool>(
      stream: playingStream,
      builder: (context, snapshot) {
        bool playing = snapshot.data != null ? snapshot.data! : false;
        return playlistUIController.hasPlayedOnce
            ? StreamBuilder<int?>(
                stream: songsStream,
                builder: (context, snapshot) {
                  SongModel currentSong =
                      playlistUIController.playlist.songs[0];
                  int? state = snapshot.data;

                  bool isHorizontal = size.width > size.height;
                  Color gradientColor = backgroundAccent;
                  if (palette != null) {
                    gradientColor = gradient
                        ? palette!.dominantColor!.color
                        : gradientColor;
                  }

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
                    currentSong = playlistUIController.playlist.songs[state];
                    // if (state != currentIndex) {
                    //   currentIndex = state;
                    //   updatePalette(currentSong.icon);
                    // }
                  } else {
                    // Fallback if stream is null (e.g., first load)
                    currentSong = playlistUIController.playlist.songs[0];
                  }

                  final songCover = Row(
                    mainAxisSize: MainAxisSize.min, // shrink-wrap horizontally
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image(
                          image: ImageParser.getImageProviderFromString(
                              currentSong.icon),
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        // 👈 replaces Expanded
                        fit: FlexFit
                            .loose, // allows flexible but not forced expansion
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return buildTitleWithFade(
                                    context,
                                    currentSong.title,
                                    titleStyle,
                                    constraints.maxWidth,
                                  );
                                },
                              ),
                            ),
                            Text(
                              currentSong.author,
                              style: authorStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final horizontalWidget = Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: songCover,
                      ),
                      //const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: x / 2),
                        child: StreamBuilder<Duration?>(
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

                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        durationFormatter(
                                          Duration(
                                            seconds: value.toInt(),
                                          ),
                                          length: maxString.length,
                                        ),
                                        style: titleStyle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width / 3,
                                      child: SliderTheme(
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
                                    Text(
                                      maxString,
                                      style: titleStyle,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: x / 2),
                        child: Row(
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
                            SizedBox(
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
                            SizedBox(
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
                        ),
                      ),
                      //const Spacer(),
                    ],
                  );

                  final widgets = [
                    songCover,
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
                    child: Padding(
                      padding: isHorizontal
                          ? EdgeInsetsGeometry.symmetric(horizontal: x / 2)
                          : EdgeInsetsGeometry.all(0),
                      child: Container(
                        height: isHorizontal ? 90 : 60,
                        width:
                            isHorizontal ? size.width - x : size.width - x / 2,
                        decoration: BoxDecoration(
                          borderRadius:
                              isHorizontal ? null : BorderRadius.circular(15),
                          color: isHorizontal ? null : gradientColor,
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
                              vertical: 5,
                              horizontal: isHorizontal ? x / 4 : x / 2),
                          child: isHorizontal
                              ? horizontalWidget
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: widgets,
                                ),
                        ),
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
