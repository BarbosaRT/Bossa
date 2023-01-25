import 'dart:async';

import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/library/library_page.dart';
import 'package:bossa/src/ui/playlist/playlist_snackbar.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/url/youtube_url_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlaylistSearch {
  Future<List<Widget>> searchLibrary({required String searchQuery}) async {
    List<Widget> playlistContainers = [];
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final homeController = Modular.get<HomeController>();

    List<PlaylistModel> playlists =
        await playlistDataManager.searchPlaylists(searchQuery: searchQuery);

    for (PlaylistModel playlist in playlists) {
      playlistContainers.add(
        LibraryContentContainer(
          title: playlist.title,
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

  Future<List<Widget>> searchYoutube(
      {required String searchQuery, required BuildContext context}) async {
    final size = MediaQuery.of(context).size;
    List<Widget> playlistContainers = [];

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final homeController = Modular.get<HomeController>();
    final audioManager = playlistManager.player;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

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
      final key = GlobalKey<DetailContainerState>();

      playlistContainers.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: UIConsts.spacing / 2),
          child: LibraryContentContainer(
            title: playlistData.title,
            author: playlistData.author,
            detailContainer: DetailContainer(
              icon: icon,
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
                            url: playlistData.url,
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
              title: playlistData.title,
            ),
            onTap: () async {
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

              int videoCount = playlistData.videoCount == null
                  ? 0
                  : playlistData.videoCount!;

              videoCount = videoCount > 10 ? 10 : videoCount;

              List<SongModel> finalSongs = [];
              var songStream = getPlaylistSongs(playlistData.id, videoCount)
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
                      final progress =
                          ((downloaded / videoCount) * 100).toInt();
                      return Text(
                        'Carregando a playlist, progresso: $progress%',
                        style: buttonTextStyle,
                      );
                    },
                  ),
                ),
              );

              await for (var _ in songStream) {}

              final finalPlaylist = PlaylistModel(
                  id: 0,
                  title: playlistData.title,
                  icon: finalSongs[0].icon,
                  songs: finalSongs);
              Asuka.hideCurrentSnackBar();
              homeController.setPlaylist(finalPlaylist);
              homeController.setCurrentPage(Pages.playlist);
              Modular.to.pushReplacementNamed(
                '/',
              );
            },
            icon: icon,
          ),
        ),
      );
    }

    yt.close();
    return playlistContainers;
  }

  Stream<List<SongModel>> getPlaylistSongs(
      PlaylistId id, int videoCount) async* {
    final youtubeExplode = YoutubeExplode();
    List<SongModel> songs = [];

    var stream = youtubeExplode.playlists.getVideos(id).take(videoCount);

    await for (var video in stream) {
      await YoutubeParser().convertYoutubeSong(video.url);
      SongModel song = await YoutubeParser().convertYoutubeSong(video.url);
      songs.add(song);
      yield songs;
    }
    youtubeExplode.close();
  }
}
