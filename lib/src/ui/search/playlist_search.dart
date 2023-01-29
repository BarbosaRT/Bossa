import 'dart:async';

import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/content_container.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/library/library_container.dart';
import 'package:bossa/src/ui/playlist/components/playlist_snackbar.dart';
import 'package:bossa/src/url/youtube_url_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistSearch {
  Future<List<PlaylistModel>> searchLibrary({
    required String searchQuery,
    PlaylistFilter filter = PlaylistFilter.idDesc,
  }) async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();

    List<PlaylistModel> playlists = await playlistDataManager.searchPlaylists(
      searchQuery: searchQuery,
      filter: filter,
    );

    return playlists;
  }

  List<Widget> getLibraryWidgets(
      {required List<PlaylistModel> playlists,
      required BuildContext context,
      required bool gridEnabled}) {
    final size = MediaQuery.of(context).size;

    List<Widget> playlistContainers = [];
    final homeController = Modular.get<HomeController>();

    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        gridEnabled
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContentContainer(
                    title: playlist.title,
                    author: '${playlist.songs.length} músicas',
                    icon: playlist.icon,
                    imagesSize: size.width / 2 - UIConsts.spacing * 0.5,
                    textWidth: size.width / 2 - UIConsts.spacing * 0.5,
                    detailContainer: PlaylistSnackbar(playlist: playlist),
                    onTap: () {
                      homeController.setPlaylist(playlist);
                      homeController.setCurrentPage(Pages.playlist);
                    }),
              )
            : LibraryContentContainer(
                title: playlist.title,
                author: '${playlist.songs.length} músicas',
                detailContainer: PlaylistSnackbar(playlist: playlist),
                onTap: () {
                  homeController.setPlaylist(playlist);
                  homeController.setCurrentPage(Pages.playlist);
                },
                icon: playlist.icon,
              ),
      );
    }

    return playlistContainers;
  }

  Future<List<PlaylistModel>> searchYoutube(
      {required String searchQuery}) async {
    List<PlaylistModel> playlistContainers = [];

    final yt = YoutubeExplode();
    final searchResponse =
        await yt.search.searchRaw(searchQuery, filter: TypeFilters.playlist);

    for (var playlistContent in searchResponse.content.toList()) {
      var playlistData = await yt.playlists.get(playlistContent.playlistId);

      final videoStream = yt.playlists.getVideos(playlistData.id).take(1);

      String icon = '';
      await for (var video in videoStream) {
        icon = YoutubeParser().getYoutubeThumbnail(video.thumbnails);
      }

      int videoCount =
          playlistData.videoCount == null ? 0 : playlistData.videoCount!;

      List<SongModel> songs = List.generate(videoCount,
          (index) => SongModel(id: 0, title: '', icon: icon, url: ''));

      playlistContainers.add(
        PlaylistModel(
          id: -1,
          title: playlistData.title,
          icon: icon,
          songs: songs.toList(),
        ),
      );
    }

    yt.close();
    return playlistContainers;
  }

  List<Widget> getYoutubeWidgets(
      {required BuildContext context,
      required List<PlaylistModel> playlists,
      required bool gridEnabled}) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    List<Widget> output = [];

    for (PlaylistModel playlist in playlists) {
      final key = GlobalKey<DetailContainerState>();
      final detailContainer = DetailContainer(
        icon: playlist.icon,
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
                      isSong: false,
                      url: playlist.url,
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
                Text('Adicionar playlist', style: buttonTextStyle),
              ]),
            ),
          ),
        ],
        title: playlist.title,
      );
      output.add(
        gridEnabled
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContentContainer(
                  title: playlist.title,
                  author: '${playlist.songs.length} músicas',
                  icon: playlist.icon,
                  imagesSize: size.width / 2 - UIConsts.spacing * 0.5,
                  textWidth: size.width / 2 - UIConsts.spacing * 0.5,
                  detailContainer: detailContainer,
                  onTap: () async {
                    await PlaylistSearch()
                        .onYoutubeTap(playlist.songs.length, playlist);
                  },
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: UIConsts.spacing / 2),
                child: LibraryContentContainer(
                  title: playlist.title,
                  author: '${playlist.songs.length} músicas',
                  detailContainer: detailContainer,
                  onTap: () async {
                    await onYoutubeTap(playlist.songs.length, playlist);
                  },
                  icon: playlist.icon,
                ),
              ),
      );
    }

    return output;
  }

  Future<void> onYoutubeTap(int videoCount, PlaylistModel playlist) async {
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundAccent = colorController.currentTheme.backgroundAccent;

    final homeController = Modular.get<HomeController>();

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);
    Asuka.showSnackBar(
      SnackBar(
        backgroundColor: backgroundAccent,
        duration: const Duration(days: 1),
        content: Text(
          'Carregando a playlist, por favor aguarde',
          style: buttonTextStyle,
        ),
      ),
    );
    Asuka.hideCurrentSnackBar();

    videoCount = videoCount > 10 ? 10 : videoCount;
    List<SongModel> finalSongs = [];
    var songStream = getPlaylistSongs(
            YoutubeParser().parseYoutubePlaylist(playlist.url!), videoCount)
        .asBroadcastStream();

    Asuka.showSnackBar(
      SnackBar(
        backgroundColor: backgroundAccent,
        duration: const Duration(days: 1),
        content: StreamBuilder<List<SongModel>>(
          stream: songStream,
          builder: (context, snapshot) {
            final downloaded =
                snapshot.data == null ? 0 : snapshot.data!.length;
            if (snapshot.data != null) {
              finalSongs = snapshot.data!;
            }
            final progress = ((downloaded / videoCount) * 100).toInt();
            return Text(
              'Carregando a playlist, progresso ($downloaded / $videoCount): $progress%',
              style: buttonTextStyle,
            );
          },
        ),
      ),
    );

    await for (var _ in songStream) {}

    final finalPlaylist = PlaylistModel(
        id: 0,
        title: playlist.title,
        icon: finalSongs[0].icon,
        songs: finalSongs);
    Asuka.hideCurrentSnackBar();
    homeController.setPlaylist(finalPlaylist);
    homeController.setCurrentPage(Pages.playlist);
    Modular.to.pushReplacementNamed(
      '/',
    );
  }

  Stream<List<SongModel>> getPlaylistSongs(String id, int videoCount) async* {
    final youtubeExplode = YoutubeExplode();
    List<SongModel> songs = [];

    var stream = youtubeExplode.playlists.getVideos(id).take(videoCount);

    await for (var video in stream) {
      SongModel song = await YoutubeParser().convertYoutubeSong(video.url);
      songs.add(song);
      yield songs;
    }
    youtubeExplode.close();
  }
}
