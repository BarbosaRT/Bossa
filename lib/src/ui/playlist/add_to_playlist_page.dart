import 'dart:async';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/library/library_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddToPlaylistPage extends StatefulWidget {
  final SongModel song;
  const AddToPlaylistPage({super.key, required this.song});

  @override
  State<AddToPlaylistPage> createState() => _AddToPlaylistPageState();
}

class _AddToPlaylistPageState extends State<AddToPlaylistPage> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  Duration delay = const Duration(milliseconds: 250);
  Timer searchTimer = Timer(const Duration(milliseconds: 250), () {});

  bool initiated = false;

  List<Widget> videoContainers = [];

  final searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    videoContainers = [];
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    List<PlaylistModel> playlists = await playlistDataManager.loadPlaylists();
    for (PlaylistModel playlist in playlists) {
      videoContainers.add(
        LibraryContentContainer(
          title: playlist.title,
          author: '${playlist.songs.length} músicas',
          useDetail: false,
          detailContainer: Container(),
          onTap: () {
            playlistDataManager.appendToPlaylist(widget.song, playlist);
            Modular.to.popUntil(ModalRoute.withName('/'));
          },
          icon: playlist.icon,
        ),
      );
    }
    videoContainers.add(
      SizedBox(
        height: 73 * 2 + x * 2,
      ),
    );

    initiated = true;
    if (mounted) {
      setState(() {});
    }
  }

  void search(String searchQuery) async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();

    videoContainers = [];

    List<PlaylistModel> playlists =
        await playlistDataManager.searchPlaylists(searchQuery: searchQuery);

    for (PlaylistModel playlist in playlists) {
      videoContainers.add(
        LibraryContentContainer(
          title: playlist.title,
          author: '${playlist.songs.length} músicas',
          useDetail: false,
          detailContainer: Container(),
          onTap: () async {
            await playlistDataManager.appendToPlaylist(widget.song, playlist);
            Modular.to.popUntil(ModalRoute.withName('/'));
          },
          icon: playlist.icon,
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
  }

  @override
  Widget build(BuildContext context) {
    if (!initiated) {
      init();
    }
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              Modular.to.popUntil(ModalRoute.withName('/'));
            },
            child: FaIcon(
              FontAwesomeIcons.xmark,
              color: contrastColor,
              size: iconSize,
            ),
          ),
        ),
        title: Text('Adicionar à playlist', style: headerStyle),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: x / 2),
                child: SizedBox(
                  width: size.width - x,
                  height: 40,
                  child: Container(
                    color: backgroundAccent,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: searchTextController,
                      decoration: InputDecoration(
                        hintText: '',
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
                height: x / 2,
              ),
              SizedBox(
                height: size.height - x * 2,
                width: size.width,
                child: ListView(
                  children: videoContainers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
