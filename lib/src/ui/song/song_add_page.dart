import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/data/youtube/youtube_parser_interface.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/theme_aware_snackbar.dart';
import 'package:bossa/src/ui/components/download_progress_widget.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/services/song_download_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

class SongAddPage extends StatefulWidget {
  final SongModel? songToBeEdited;
  const SongAddPage({super.key, this.songToBeEdited});

  @override
  State<SongAddPage> createState() => _SongAddPageState();
}

class _SongAddPageState extends State<SongAddPage> {
  static String defaultIcon = UIConsts.assetImage;
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  final titleTextController = TextEditingController();
  final authorTextController = TextEditingController();

  final scrollController = ScrollController();

  bool editing = false;
  bool saveOffline = false;
  bool isDownloading = false;
  String? currentDownloadId;

  final SongModel defaultSong = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: '',
      path: '',
      author: 'author');

  SongModel songToBeAdded = SongModel(
      id: 0,
      title: 'title',
      icon: defaultIcon,
      url: '',
      path: '',
      author: 'author');

  @override
  void initState() {
    super.initState();

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (widget.songToBeEdited != null) {
      songToBeAdded = SongModel.fromMap(widget.songToBeEdited!.toMap());
      editing = true;
      titleTextController.text = songToBeAdded.title;
      authorTextController.text = songToBeAdded.author;
    }
  }

  void saveIcon() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        songToBeAdded.icon = file.path!;
      });
    }
  }

  void saveSong() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mp3', 'flac', 'wav', 'm4a']);

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        songToBeAdded.path = file.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final songDataManager = Modular.get<SongDataManager>();
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentTheme.accentColor;
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    TextStyle titleStyle = TextStyles().headline.copyWith(color: contrastColor);

    TextStyle authorStyle =
        TextStyles().headline2.copyWith(color: contrastColor);

    TextStyle snackbarStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    ImageProvider iconImage =
        ImageParser.getImageProviderFromString(songToBeAdded.icon);

    final offlineWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: x / 2),
      child: Container(
        width: size.width,
        height: x * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: backgroundAccent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'avaliable-offline'.i18n(),
              style: snackbarStyle,
            ),
            Switch(
              value: songToBeAdded.path.isNotEmpty,
              onChanged: isDownloading
                  ? null
                  : (value) async {
                      if (!value) {
                        // Delete offline files
                        final downloadManager = SongDownloadManager();
                        await downloadManager.deleteSongFiles(songToBeAdded);

                        songToBeAdded.icon = '';
                        if (SongParser().isSongFromYoutube(songToBeAdded.url)) {
                          final youtubeParser = Modular.get<YoutubeParserInterface>();
                          final song = await youtubeParser.convertYoutubeSong(songToBeAdded.url);
                          songToBeAdded.icon = song.icon;
                        } else {
                          songToBeAdded.icon = UIConsts.assetImage;
                        }
                        if (mounted) {
                          setState(() {});
                        }
                        return;
                      }

                      // Start download with progress tracking
                      setState(() {
                        isDownloading = true;
                        currentDownloadId =
                            songToBeAdded.url.hashCode.toString();
                      });

                      try {
                        songToBeAdded = await SongParser().parseSongBeforeSave(
                          songToBeAdded,
                          saveOffline: true,
                          onProgress: (progress) {
                            // Progress is handled by DownloadProgressWidget
                          },
                        );

                        // Use a post-frame callback to avoid BuildContext async gap
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            ThemeAwareSnackbar.show(
                              context: context,
                              message: 'successful-download'.i18n(),
                            );
                          }
                        });
                      } catch (e) {
                        // Use a post-frame callback to avoid BuildContext async gap
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            ThemeAwareSnackbar.show(
                              context: context,
                              message: 'download-failed'.i18n(),
                            );
                          }
                        });
                      } finally {
                        if (mounted) {
                          setState(() {
                            isDownloading = false;
                            currentDownloadId = null;
                          });
                        }
                      }
                    },
            )
          ],
        ),
      ),
    );

    bool isHorizontal = size.width > size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: Padding(
          padding: EdgeInsets.only(left: x),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (widget.songToBeEdited != songToBeAdded) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: backgroundAccent,
                        title: Text(
                          'changes-msg'.i18n(),
                          style: snackbarStyle,
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Modular.to.popAndPushNamed('/');
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      'yes'.i18n(),
                                      style: snackbarStyle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      'no'.i18n(),
                                      style: snackbarStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Modular.to.popAndPushNamed('/');
                }
              },
              child: FaIcon(
                FontAwesomeIcons.xmark,
                color: contrastColor,
                size: iconSize * 1.5,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: x),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  songToBeAdded =
                      await SongParser().parseSongBeforeSave(songToBeAdded);
                  if (!mounted) return;

                  editing
                      ? songDataManager.editSong(songToBeAdded)
                      : songDataManager.addSong(songToBeAdded);

                  Modular.to.popUntil(ModalRoute.withName('/'));
                },
                child: FaIcon(
                  editing
                      ? FontAwesomeIcons.solidPenToSquare
                      : FontAwesomeIcons.solidFloppyDisk,
                  color: contrastColor,
                  size: editing ? iconSize : iconSize * 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: ListView(
            children: [
              Container(
                width: size.width,
                height: size.height - x * 2 - 40,
                color: backgroundColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: x / 2),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: size.width,
                          height: size.width + x * 3,
                          child: Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: (isHorizontal
                                          ? size.height / 2
                                          : size.width / 2) -
                                      x * 2,
                                  height: (isHorizontal
                                          ? size.height / 2
                                          : size.width / 2) -
                                      x * 2,
                                  child: GestureDetector(
                                    onTap: saveIcon,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: iconImage,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: x * 2.5,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: x / 2),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: size.width,
                                        height: x * 1.5,
                                        child: TextField(
                                          controller: titleTextController,
                                          decoration: InputDecoration(
                                            hintText: 'title'.i18n(),
                                            hintStyle: titleStyle,
                                            border: InputBorder.none,
                                            isDense: true,
                                            helperMaxLines: 1,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: titleStyle,
                                          textAlign: TextAlign.center,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          onChanged: (value) {
                                            setState(() {
                                              songToBeAdded.title = value;
                                            });
                                          },
                                          onSubmitted: (value) {
                                            setState(() {
                                              songToBeAdded.title = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width,
                                        height: x,
                                        child: TextField(
                                          controller: authorTextController,
                                          decoration: InputDecoration(
                                              hintText: 'author'.i18n(),
                                              hintStyle: authorStyle,
                                              border: InputBorder.none),
                                          style: authorStyle,
                                          textAlign: TextAlign.center,
                                          onChanged: (value) {
                                            setState(() {
                                              songToBeAdded.author = value;
                                            });
                                          },
                                          onSubmitted: (value) {
                                            setState(() {
                                              songToBeAdded.author = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              songToBeAdded.url.isNotEmpty
                                  ? offlineWidget
                                  : Container(),
                              // Download progress widget
                              if (currentDownloadId != null)
                                DownloadProgressWidget(
                                  downloadId: currentDownloadId!,
                                  title: songToBeAdded.title.isNotEmpty
                                      ? songToBeAdded.title
                                      : 'downloading-song'.i18n(),
                                  onCancel: () {
                                    setState(() {
                                      isDownloading = false;
                                      currentDownloadId = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: iconSize * 0.5,
                        right: x / 2,
                        child: SizedBox(
                          width: iconSize,
                          height: 50,
                          child: GestureDetector(
                            onTap: saveSong,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.music,
                                  color: contrastColor,
                                  size: iconSize,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                songToBeAdded.path.isEmpty &&
                                        songToBeAdded.url.isEmpty
                                    ? Container()
                                    : Container(
                                        width: 30,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: contrastColor,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
