import 'dart:async';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/library/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final urlTextController = TextEditingController();
  static double x = 30;
  double iconSize = UIConsts.iconSize.toDouble();
  bool searchEnabled = true;
  Duration delay = const Duration(milliseconds: 250);
  Timer searchTimer = Timer(const Duration(milliseconds: 250), () {});
  List<Video> videos = [];

  void search(String searchQuery) async {
    if (!searchEnabled) {
      return;
    }
    searchEnabled = false;
    final yt = YoutubeExplode();

    final searchResponse = await yt.search.search(searchQuery);
    setState(() {
      videos = searchResponse.toList();
    });

    yt.close();

    Future.delayed(delay).then((value) {
      searchEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final songDataManager = Modular.get<SongDataManager>();
    final audioManager = playlistManager.player;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);
    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    List<Widget> videoContainers = [];
    for (var video in videos) {
      final icon = YoutubeParser().getYoutubeThumbnailFromVideo(video);
      videoContainers.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: x / 2),
          child: LibraryContentContainer(
            title: video.title,
            author: video.author,
            detailContainer: DetailContainer(
              icon: icon,
              actions: [
                SizedBox(
                  width: size.width,
                  height: 30,
                  child: GestureDetector(
                    onTap: () async {
                      SongModel song =
                          await YoutubeParser().convertYoutubeSong(video.url);
                      song = await SongParser().parseSongBeforeSave(song);
                      songDataManager.addSong(song);
                      setState(() {});
                    },
                    child: Row(children: [
                      FaIcon(
                        FontAwesomeIcons.plus,
                        size: iconSize,
                        color: contrastColor,
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Text('Adicionar Música', style: buttonTextStyle),
                    ]),
                  ),
                ),
                SizedBox(
                  width: size.width,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(children: [
                      FaIcon(
                        FontAwesomeIcons.list,
                        size: iconSize,
                        color: contrastColor,
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Text('Adicionar á uma playlist ', style: buttonTextStyle),
                    ]),
                  ),
                ),
              ],
              title: video.title,
            ),
            onTap: () async {
              SongModel song =
                  await YoutubeParser().convertYoutubeSong(video.url);
              song.id = -1;
              PlaylistModel playlist = PlaylistModel(
                  id: 0, title: 'Todas as Músicas', icon: icon, songs: [song]);

              audioManager.pause();
              playlistUIController.setPlaylist(playlist);
              Modular.to.pushReplacementNamed(
                '/player',
                arguments: playlist,
              );
            },
            icon: icon,
          ),
        ),
      );
    }

    videoContainers.add(
      SizedBox(
        height: 73 * 2 + x * 2,
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: x / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(left: x / 2),
                  child: Text('Buscar', style: headerStyle),
                ),
                SizedBox(
                  height: x / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(left: x / 2),
                  child: SizedBox(
                    width: size.width - x,
                    height: 40,
                    child: Container(
                      color: backgroundAccent,
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: urlTextController,
                        decoration: InputDecoration(
                          hintText: 'O que você quer ouvir?',
                          hintStyle: titleStyle,
                          isDense: true,
                          helperMaxLines: 1,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          icon: FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: contrastColor,
                          ),
                        ),
                        style: titleStyle,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (searchQuery) {
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () {
                            search(searchQuery);
                          });
                        },
                        onSubmitted: (searchQuery) {
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () {
                            search(searchQuery);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: x,
                ),
                SizedBox(
                  height: size.height - x * 2,
                  width: size.width,
                  child: ListView(
                    children: videoContainers,
                  ),
                ),
                SizedBox(
                  height: x / 2,
                ),
                Padding(
                  padding: EdgeInsets.only(left: x / 2),
                  child: SizedBox(
                    width: size.width - x,
                    height: 40,
                    child: Container(
                      color: backgroundAccent,
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: urlTextController,
                        decoration: InputDecoration(
                          hintText: 'O que você quer ouvir?',
                          hintStyle: titleStyle,
                          isDense: true,
                          helperMaxLines: 1,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          icon: FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: contrastColor,
                          ),
                        ),
                        style: titleStyle,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (searchQuery) {
                          Future.delayed(Duration(
                                  milliseconds: delay.inMilliseconds + 50))
                              .then(
                            (value) {
                              search(searchQuery);
                            },
                          );
                        },
                        onSubmitted: (searchQuery) {
                          Future.delayed(Duration(
                                  milliseconds: delay.inMilliseconds + 50))
                              .then(
                            (value) {
                              search(searchQuery);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: x,
                ),
                SizedBox(
                  height: size.height - x * 2,
                  width: size.width,
                  child: ListView(
                    children: videoContainers,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
