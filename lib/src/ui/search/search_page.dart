import 'dart:async';
import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/library/library_page.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:bossa/src/url/youtube_url_add_page.dart';
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
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();

  bool searchLibrary = false;
  bool isSearching = true;
  Duration delay = const Duration(milliseconds: 250);
  Timer searchTimer = Timer(const Duration(milliseconds: 250), () {});

  List<Widget> videoContainers = [];

  @override
  void initState() {
    super.initState();
    final homeController = Modular.get<HomeController>();

    if (!searchLibrary) {
      urlTextController.text = homeController.lastSearchedTopic;
    } else {
      urlTextController.text = '';
    }
    homeController.addListener(() {
      searchLibrarySetter();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void searchLibrarySetter() {
    final homeController = Modular.get<HomeController>();
    searchLibrary = homeController.searchLibrary;
  }

  Future<void> search(String searchQuery) async {
    final size = MediaQuery.of(context).size;
    final homeController = Modular.get<HomeController>();

    if (!searchLibrary) {
      homeController.setlastSearchedTopic(searchQuery);
    }

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final songDataManager = Modular.get<SongDataManager>();
    final audioManager = playlistManager.player;

    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    videoContainers = [];

    if (searchLibrary) {
      List<SongModel> songs =
          await songDataManager.searchSongs(searchQuery: searchQuery);

      for (SongModel song in songs) {
        List<SongModel> songsForPlaylist = songs.toList();
        songsForPlaylist.remove(song);
        songsForPlaylist.insert(0, song);
        PlaylistModel playlist = PlaylistModel(
            id: 0,
            title: 'Todas as Músicas',
            icon: song.icon,
            songs: songsForPlaylist);

        videoContainers.add(
          LibraryContentContainer(
            title: song.title,
            author: song.author,
            detailContainer: DetailContainer(
              icon: song.icon,
              actions: [
                SizedBox(
                  width: size.width,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      songDataManager.removeSong(song);
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
                      Text('Remover ', style: buttonTextStyle),
                    ]),
                  ),
                ),
                SizedBox(
                  width: size.width,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
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
                        size: iconSize,
                        color: contrastColor,
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Text('Editar ', style: buttonTextStyle),
                    ]),
                  ),
                ),
              ],
              title: song.title,
            ),
            onTap: () {
              Modular.to.popUntil(ModalRoute.withName('/'));
              audioManager.pause();
              playlistUIController.setPlaylist(playlist);
              Modular.to.pushReplacementNamed(
                '/player',
                arguments: playlist,
              );
              audioManager.play();
            },
            icon: song.icon,
          ),
        );
      }
      videoContainers.add(
        SizedBox(
          height: 73 * 2 + x * 2,
        ),
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    final yt = YoutubeExplode();
    final searchResponse = await yt.search.search(searchQuery);

    for (var video in searchResponse.toList()) {
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
                      Asuka.hideCurrentSnackBar();
                      Modular.to.push(
                        MaterialPageRoute(
                          builder: (context) => YoutubeUrlAddPage(
                            isSong: true,
                            url: video.url,
                          ),
                        ),
                      );
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
                    onTap: () {
                      Asuka.hideCurrentSnackBar();
                      Modular.to.push(
                        MaterialPageRoute(
                          builder: (context) => YoutubeUrlAddPage(
                              isSong: true,
                              url: video.url,
                              addToPlaylist: true),
                        ),
                      );
                    },
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

              SongModel song =
                  await YoutubeParser().convertYoutubeSong(video.url);

              Asuka.hideCurrentSnackBar();

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
    if (mounted) {
      setState(() {});
    }
    yt.close();
  }

  //
  // Build
  //
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final homeController = Modular.get<HomeController>();
    if (homeController.searchLibrary != searchLibrary) {
      searchLibrarySetter();
      setState(() {});
    }

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);

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
                  child: Text(searchLibrary ? 'Buscar na Biblioteca' : 'Buscar',
                      style: headerStyle),
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
                          print(searchQuery);
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () async {
                            setState(() {
                              isSearching = true;
                            });
                            await search(searchQuery);
                            setState(() {
                              isSearching = false;
                            });
                          });
                        },
                        onSubmitted: (searchQuery) {
                          searchTimer.cancel();
                          searchTimer = Timer(
                              Duration(milliseconds: delay.inMilliseconds + 50),
                              () async {
                            setState(() {
                              isSearching = true;
                            });
                            await search(searchQuery);
                            setState(() {
                              isSearching = false;
                            });
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
                  height: size.height - x * 5,
                  width: size.width,
                  child: isSearching
                      ? const Align(
                          alignment: Alignment.topCenter,
                          child: CircularProgressIndicator(),
                        )
                      : ListView(
                          children: videoContainers,
                        ),
                ),
                SizedBox(
                  height: x / 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
