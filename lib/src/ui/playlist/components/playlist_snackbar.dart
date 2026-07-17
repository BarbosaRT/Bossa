import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/ui/components/theme_aware_snackbar.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/services/song_download_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistSnackbar extends StatefulWidget {
  final PlaylistModel playlist;
  final void Function()? callback;
  const PlaylistSnackbar({super.key, required this.playlist, this.callback});

  @override
  State<PlaylistSnackbar> createState() => _PlaylistSnackbarState();
}

class _PlaylistSnackbarState extends State<PlaylistSnackbar> {
  double iconSize = UIConsts.iconSize.toDouble();
  bool canTapOffline = true;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Stream<List<SongModel>> downloadPlaylistSongs() async* {
    List<SongModel> output = [];
    final songDataManager = Modular.get<SongDataManager>();
    final downloadManager = SongDownloadManager();

    for (int i = 0; i < widget.playlist.songs.length; i++) {
      SongModel song = widget.playlist.songs[i];

      try {
        // Download with robust system
        song = await downloadManager.downloadSong(
          song,
          downloadOffline: true,
          onProgress: (progress) {
            // Progress tracking handled by download state manager
          },
        );

        songDataManager.editSong(song);
        output.add(song);
        yield output;
      } catch (e) {
        // If download fails, add original song
        output.add(song);
        yield output;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final accentColor = colorController.currentTheme.accentColor;

    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final songDataManager = Modular.get<SongDataManager>();

    final buttonStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);
    final key = GlobalKey<DetailContainerState>();

    TextStyle authorStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    bool isOffline = false;
    for (SongModel song in widget.playlist.songs) {
      if (song.path.isEmpty) {
        isOffline = false;
        break;
      }
      isOffline = true;
    }

    return DetailContainer(
      icon: widget.playlist.icon,
      title: widget.playlist.title,
      key: key,
      actions: [
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () {
              key.currentState?.pop();
              playlistDataManager.deletePlaylist(widget.playlist);
              widget.callback?.call();
            },
            child: Row(children: [
              FaIcon(
                FontAwesomeIcons.trash,
                size: iconSize,
                color: contrastColor,
              ),
              SizedBox(
                width: iconSize / 2,
              ),
              Text('remove'.i18n(), style: buttonStyle),
            ]),
          ),
        ),
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () {
              key.currentState?.pop();
              Modular.to.push(
                MaterialPageRoute(
                  builder: (context) => PlaylistAddPage(
                    playlistToBeEdited: widget.playlist,
                  ),
                ),
              );
            },
            child: Row(children: [
              FaIcon(
                FontAwesomeIcons.penToSquare,
                size: iconSize,
                color: contrastColor,
              ),
              SizedBox(
                width: iconSize / 2,
              ),
              Text('edit'.i18n(), style: buttonStyle),
            ]),
          ),
        ),
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () {
              key.currentState?.pop();
              for (SongModel song in widget.playlist.songs) {
                songDataManager.removeSong(song);
              }
              playlistDataManager.deletePlaylist(widget.playlist);

              widget.callback?.call();
            },
            child: Row(children: [
              FaIcon(
                FontAwesomeIcons.solidSquareMinus,
                size: iconSize,
                color: contrastColor,
              ),
              SizedBox(
                width: iconSize / 2,
              ),
              Text('remove-all-songs-playlist'.i18n(), style: buttonStyle),
            ]),
          ),
        ),
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () async {
              if (!canTapOffline) {
                return;
              }
              key.currentState?.pop();
              canTapOffline = false;

              // Store context before async operations
              final scaffoldContext = context;

              if (isOffline) {
                ThemeAwareSnackbar.show(
                  context: scaffoldContext,
                  message: 'removing-songs'.i18n(),
                  duration: const Duration(days: 1),
                );

                widget.playlist.icon = '';
                final downloadManager = SongDownloadManager();

                for (SongModel song in widget.playlist.songs) {
                  // Use robust delete method
                  await downloadManager.deleteSongFiles(song);

                  song.icon = '';
                  song.path = '';

                  if (SongParser().isSongFromYoutube(song.url)) {
                    final yt = YoutubeExplode();
                    final video = await yt.videos
                        .get(SongParser().parseYoutubeSongUrl(song.url));
                    song.icon =
                        YoutubeParser().getYoutubeThumbnail(video.thumbnails);
                  } else {
                    song.icon = UIConsts.assetImage;
                  }

                  songDataManager.editSong(song);

                  if (widget.playlist.icon.isEmpty) {
                    widget.playlist.icon = song.icon;
                  }
                }

                // Use a post-frame callback to avoid BuildContext async gap
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ThemeAwareSnackbar.showCustom(
                      context: context,
                      backgroundColor: accentColor,
                      content: Text(
                        'success-remove'.i18n(),
                        style: authorStyle,
                      ),
                    );
                  }
                });

                isOffline = false;
                canTapOffline = true;

                await playlistDataManager.editPlaylist(widget.playlist);
                if (mounted) {
                  setState(() {});
                }
                widget.callback?.call();
                return;
              }

              Stream<List<SongModel>> donwloadStream =
                  downloadPlaylistSongs().asBroadcastStream();

              // Show progress snackbar immediately (before async operations)
              ThemeAwareSnackbar.showCustom(
                context: scaffoldContext,
                duration: const Duration(days: 1),
                content: StreamBuilder<List<SongModel>>(
                  stream: donwloadStream,
                  builder: (context, snapshot) {
                    final downloaded =
                        snapshot.data == null ? 0 : snapshot.data!.length;
                    final progress =
                        ((downloaded / widget.playlist.songs.length) * 100)
                            .toInt();
                    return Text(
                      '${"progress-playlist".i18n()} ($downloaded / ${widget.playlist.songs.length}):  $progress%',
                      style: authorStyle,
                    );
                  },
                ),
              );

              List<SongModel> finalSongList = [];
              await for (var songsList in donwloadStream) {
                finalSongList = songsList.toList();
              }

              widget.playlist.songs = finalSongList.toList();
              widget.playlist.icon = widget.playlist.songs[0].icon;

              await playlistDataManager.editPlaylist(widget.playlist);

              isOffline = true;
              canTapOffline = true;

              // Use a post-frame callback to avoid BuildContext async gap
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ThemeAwareSnackbar.showCustom(
                    context: context,
                    backgroundColor: accentColor,
                    content: Text(
                      'successful-download'.i18n(),
                      style: authorStyle,
                    ),
                  );
                }
              });

              if (mounted) {
                setState(() {});
              }
              widget.callback?.call();
            },
            child: Row(children: [
              FaIcon(
                isOffline
                    ? FontAwesomeIcons.solidSquareCheck
                    : FontAwesomeIcons.squareCheck,
                size: iconSize,
                color: contrastColor,
              ),
              SizedBox(
                width: iconSize / 2,
              ),
              Text('avaliable-offline'.i18n(), style: buttonStyle),
            ]),
          ),
        ),
      ],
    );
  }
}
