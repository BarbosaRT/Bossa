import 'dart:io';

import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  Stream<List<SongModel>> downloadPlaylistSongs() async* {
    List<SongModel> output = [];
    for (SongModel song in widget.playlist.songs) {
      song = await SongParser().parseSongBeforeSave(
        song,
        saveOffline: true,
      );
      output.add(song);
      yield output;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final accentColor = colorController.currentScheme.accentColor;

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
              Text('Remover', style: buttonStyle),
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
              Text('Editar', style: buttonStyle),
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
              Text('Remover todas as músicas da playlist', style: buttonStyle),
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
              if (isOffline) {
                Asuka.showSnackBar(
                  SnackBar(
                    backgroundColor: backgroundAccent,
                    duration: const Duration(days: 1),
                    content: Text(
                      'Excluindo os arquivos das músicas, aguarde',
                      style: authorStyle,
                    ),
                  ),
                );

                widget.playlist.icon = '';
                for (SongModel song in widget.playlist.songs) {
                  final icon = File(song.icon);
                  final path = File(song.path);

                  if (await icon.exists()) {
                    song.icon = '';
                    await icon.delete();
                  }
                  if (await path.exists()) {
                    song.path = '';
                    await path.delete();
                  }

                  if (SongParser().isSongFromYoutube(song.url)) {
                    final yt = YoutubeExplode();
                    final video = await yt.videos
                        .get(SongParser().parseYoutubeSongUrl(song.url));
                    song.icon =
                        YoutubeParser().getYoutubeThumbnail(video.thumbnails);
                  } else {
                    song.icon = UIConsts.assetImage;
                  }

                  if (widget.playlist.icon.isEmpty) {
                    widget.playlist.icon = song.icon;
                  }
                }

                Asuka.hideCurrentSnackBar();
                Asuka.showSnackBar(
                  SnackBar(
                    backgroundColor: accentColor,
                    content: Text(
                      'Arquivos removidos com sucesso',
                      style: authorStyle,
                    ),
                  ),
                );

                isOffline = false;
                canTapOffline = true;

                if (mounted) {
                  setState(() {});
                }
                widget.callback?.call();
                return;
              }

              Stream<List<SongModel>> donwloadStream =
                  downloadPlaylistSongs().asBroadcastStream();

              Asuka.showSnackBar(
                SnackBar(
                  backgroundColor: backgroundAccent,
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
                        'Baixando as músicas, progresso ($downloaded / ${widget.playlist.songs.length}):  $progress%',
                        style: authorStyle,
                      );
                    },
                  ),
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

              Asuka.hideCurrentSnackBar();
              Asuka.showSnackBar(
                SnackBar(
                  backgroundColor: accentColor,
                  content: Text(
                    'Músicas baixadas com sucesso',
                    style: authorStyle,
                  ),
                ),
              );

              widget.callback?.call();

              if (mounted) {
                setState(() {});
              }
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
              Text('Disponivel Offline', style: buttonStyle),
            ]),
          ),
        ),
      ],
    );
  }
}