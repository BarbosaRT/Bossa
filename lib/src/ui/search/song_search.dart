import 'dart:async';
import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/content_container.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/library/library_container.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:bossa/src/url/youtube_url_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongSearch {
  Future<List<SongModel>> searchLibrary({
    required String searchQuery,
    SongFilter filter = SongFilter.idDesc,
  }) async {
    final songDataManager = Modular.get<SongDataManager>();
    List<SongModel> songs = await songDataManager.searchSongs(
        searchQuery: searchQuery, filter: filter);
    return songs;
  }

  List<Widget> getLibraryWidgets(
      {required List<SongModel> songs,
      required BuildContext context,
      required bool gridEnabled}) {
    final size = MediaQuery.of(context).size;
    final songDataManager = Modular.get<SongDataManager>();
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;

    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    List<Widget> songContainers = [];

    for (SongModel song in songs) {
      PlaylistModel playlist = PlaylistModel(
          id: 0, title: 'Todas as Músicas', icon: song.icon, songs: songs);
      final key = GlobalKey<DetailContainerState>();
      final detailContainer = DetailContainer(
        icon: song.icon,
        key: key,
        actions: [
          SizedBox(
            width: size.width,
            height: 30,
            child: GestureDetector(
              onTap: () {
                key.currentState?.pop();
                songDataManager.removeSong(song);
              },
              child: Row(children: [
                FaIcon(
                  FontAwesomeIcons.trash,
                  size: UIConsts.iconSize.toDouble(),
                  color: contrastColor,
                ),
                SizedBox(
                  width: UIConsts.iconSize.toDouble() / 2,
                ),
                Text('Remover', style: buttonTextStyle),
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
                    builder: (context) => SongAddPage(
                      songToBeEdited: song,
                    ),
                  ),
                );
              },
              child: Row(children: [
                FaIcon(
                  FontAwesomeIcons.penToSquare,
                  size: UIConsts.iconSize.toDouble(),
                  color: contrastColor,
                ),
                SizedBox(
                  width: UIConsts.iconSize.toDouble() / 2,
                ),
                Text('Editar', style: buttonTextStyle),
              ]),
            ),
          ),
        ],
        title: song.title,
      );

      songContainers.add(
        gridEnabled
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContentContainer(
                    title: song.title,
                    author: song.author,
                    icon: song.icon,
                    imagesSize: size.width / 2 - UIConsts.spacing * 0.5,
                    textWidth: size.width / 2 - UIConsts.spacing * 1.75,
                    detailContainer: detailContainer,
                    onTap: () {
                      Modular.to.popUntil(ModalRoute.withName('/'));
                      audioManager.pause();

                      playlistUIController.setPlaylist(playlist);
                      playlistManager.setPlaylist(playlist,
                          initialIndex: songs.indexOf(song));

                      Modular.to.pushReplacementNamed(
                        '/player',
                      );
                      audioManager.play();
                    }),
              )
            : LibraryContentContainer(
                title: song.title,
                author: song.author,
                detailContainer: detailContainer,
                onTap: () async {
                  Modular.to.popUntil(ModalRoute.withName('/'));
                  audioManager.pause();

                  playlistUIController.setPlaylist(playlist);
                  await playlistManager.setPlaylist(playlist,
                      initialIndex: songs.indexOf(song));

                  Modular.to.pushReplacementNamed(
                    '/player',
                  );
                  audioManager.play();
                },
                icon: song.icon,
              ),
      );
    }
    return songContainers;
  }

  Future<List<SongModel>> searchYoutube({
    required String searchQuery,
  }) async {
    List<SongModel> songs = [];

    final yt = YoutubeExplode();
    final searchResponse = await yt.search.search(searchQuery);

    for (var video in searchResponse.toList()) {
      final icon = YoutubeParser().getYoutubeThumbnail(video.thumbnails);
      songs.add(SongModel(
        id: -1,
        icon: icon,
        title: video.title,
        author: video.author,
        url: video.url,
      ));
    }

    return songs;
  }

  List<Widget> getYoutubeWidgets(
      {required List<SongModel> songs,
      required BuildContext context,
      required bool gridEnabled}) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    List<Widget> songContainers = [];

    for (var song in songs) {
      final key = GlobalKey<DetailContainerState>();
      final detailContainer = DetailContainer(
        icon: song.icon,
        key: key,
        actions: [
          SizedBox(
            width: size.width,
            height: 30,
            child: GestureDetector(
              onTap: () async {
                key.currentState?.pop();
                Modular.to.push(
                  MaterialPageRoute(
                    builder: (context) => YoutubeUrlAddPage(
                      isSong: true,
                      url: song.url,
                    ),
                  ),
                );
              },
              child: Row(children: [
                FaIcon(
                  FontAwesomeIcons.plus,
                  size: UIConsts.iconSize.toDouble(),
                  color: contrastColor,
                ),
                SizedBox(
                  width: UIConsts.iconSize.toDouble() / 2,
                ),
                Text('Adicionar Música', style: buttonTextStyle),
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
                    builder: (context) => YoutubeUrlAddPage(
                        isSong: true, url: song.url, addToPlaylist: true),
                  ),
                );
              },
              child: Row(children: [
                FaIcon(
                  FontAwesomeIcons.list,
                  size: UIConsts.iconSize.toDouble(),
                  color: contrastColor,
                ),
                SizedBox(
                  width: UIConsts.iconSize.toDouble() / 2,
                ),
                Text('Adicionar á uma playlist', style: buttonTextStyle),
              ]),
            ),
          ),
        ],
        title: song.title,
      );
      songContainers.add(gridEnabled
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ContentContainer(
                  title: song.title,
                  author: song.author,
                  icon: song.icon,
                  imagesSize: size.width / 2 - UIConsts.spacing * 0.5,
                  textWidth: size.width / 2 - UIConsts.spacing * 1.75,
                  detailContainer: detailContainer,
                  onTap: () async {
                    await onYoutubeTap(song.url, song.icon);
                  }),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: UIConsts.spacing / 2),
              child: LibraryContentContainer(
                title: song.title,
                author: song.author,
                detailContainer: detailContainer,
                onTap: () async {
                  await onYoutubeTap(song.url, song.icon);
                },
                icon: song.icon,
              ),
            ));
    }
    return songContainers;
  }

  Future<void> onYoutubeTap(String url, String icon) async {
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    Asuka.showSnackBar(
      SnackBar(
        backgroundColor: backgroundAccent,
        duration: const Duration(days: 1),
        content: Text(
          'Carregando a música, por favor aguarde',
          style: buttonTextStyle,
        ),
      ),
    );

    SongModel song = await YoutubeParser().convertYoutubeSong(url);

    Asuka.hideCurrentSnackBar();

    song.id = -1;
    PlaylistModel playlist = PlaylistModel(
        id: 0, title: 'Todas as Músicas', icon: icon, songs: [song]);

    audioManager.pause();
    playlistUIController.setPlaylist(playlist);
    playlistManager.setPlaylist(playlist);
    Modular.to.pushReplacementNamed(
      '/player',
      arguments: playlist,
    );
  }
}
