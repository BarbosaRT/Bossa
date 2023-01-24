import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/playlist_audio_manager.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/playlist/playlist_snackbar.dart';
import 'package:bossa/src/ui/playlist/playlist_ui_controller.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:text_scroll/text_scroll.dart';

class LibraryContentContainer extends StatefulWidget {
  final Widget detailContainer;
  final void Function() onTap;
  final String icon;
  final String title;
  final String? author;
  final bool? useDetail;
  const LibraryContentContainer(
      {super.key,
      required this.detailContainer,
      required this.onTap,
      required this.icon,
      required this.title,
      this.author,
      this.useDetail});

  @override
  State<LibraryContentContainer> createState() =>
      _LibraryContentContainerState();
}

class _LibraryContentContainerState extends State<LibraryContentContainer> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;
    final contrastColor = colorController.currentScheme.contrastColor;
    final contrastAccent = colorController.currentScheme.contrastAccent;

    TextStyle titleStyle = TextStyles().boldHeadline2.copyWith(
          color: contrastColor,
        );
    TextStyle authorStyle = TextStyles().headline3.copyWith(
          color: contrastAccent,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          if (widget.useDetail == false) {
            return;
          }
          Asuka.showModalBottomSheet(
              backgroundColor: backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              builder: (context) {
                return widget.detailContainer;
              });
        },
        child: Container(
          width: size.width,
          height: 70,
          decoration: BoxDecoration(
            color: backgroundAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Image(
                  image: ImageParser.getImageProviderFromString(
                    widget.icon,
                  ),
                  fit: BoxFit.cover,
                  alignment: FractionalOffset.center,
                  width: 60,
                  height: 60,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width - 160,
                    height: 20,
                    child: TextScroll(
                      widget.title,
                      mode: TextScrollMode.endless,
                      velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
                      delayBefore: const Duration(seconds: 10),
                      pauseBetween: const Duration(seconds: 5),
                      style: titleStyle,
                      textAlign: TextAlign.right,
                      selectable: true,
                    ),
                  ),
                  widget.author == null
                      ? Container()
                      : Text(
                          widget.author!,
                          style: authorStyle,
                        ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Asuka.showModalBottomSheet(
                      backgroundColor: backgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      builder: (context) {
                        return widget.detailContainer;
                      });
                },
                child: FaIcon(
                  FontAwesomeIcons.bars,
                  color: contrastColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  double iconSize = UIConsts.iconSize.toDouble();
  static double x = UIConsts.spacing;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<PlaylistModel> playlists = [];
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadSongs();
    loadPlaylists();
  }

  void loadSongs() async {
    final songDataManager = Modular.get<SongDataManager>();
    songs = await songDataManager.loadAllSongs();
    setState(() {});
  }

  void loadPlaylists() async {
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    playlists = await playlistDataManager.loadPlaylists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final accentColor = colorController.currentScheme.accentColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final songDataManager = Modular.get<SongDataManager>();
    final playlistManager = Modular.get<JustPlaylistManager>();
    final playlistUIController = Modular.get<PlaylistUIController>();
    final audioManager = playlistManager.player;
    final homeController = Modular.get<HomeController>();

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    final buttonTextStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
    );

    List<Widget> songContainers = [];
    for (SongModel song in songs) {
      List<SongModel> songsForPlaylist = songs.toList();
      songsForPlaylist.remove(song);
      songsForPlaylist.insert(0, song);
      PlaylistModel playlist = PlaylistModel(
          id: 0,
          title: 'Todas as Músicas',
          icon: song.icon,
          songs: songsForPlaylist);
      songContainers.add(
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
                    loadSongs();
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

    List<Widget> playlistContainers = [];
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

    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: x / 2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: x / 2),
            child: Row(
              children: [
                Text('Sua Biblioteca', style: headerStyle),
                const Spacer(
                  flex: 1,
                ),
                SizedBox(
                  width: 3 * iconSize / 2,
                  height: 3 * iconSize / 2,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      homeController.setCurrentPage(Pages.search);
                      homeController.setSearchLibrary(true);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: contrastColor,
                      size: iconSize,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const AddWidget()
              ],
            ),
          ),
          SizedBox(
            height: size.height - 180,
            width: size.width,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool isScroll) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    backgroundColor: backgroundColor,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(15),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: backgroundAccent,
                        ),
                        child: TabBar(
                          onTap: (value) {
                            loadSongs();
                            setState(() {});
                          },
                          padding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelPadding: EdgeInsets.zero,
                          controller: _tabController,
                          isScrollable: true,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          tabs: [
                            Container(
                              width: (size.width - x / 2) / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _tabController.index == 0
                                    ? accentColor
                                    : backgroundAccent,
                              ),
                              child: Center(
                                child: Text(
                                  'Playlists',
                                  style: headerStyle,
                                ),
                              ),
                            ),
                            Container(
                              width: (size.width - x / 2) / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _tabController.index == 1
                                    ? accentColor
                                    : backgroundAccent,
                              ),
                              child: Center(
                                child: Text(
                                  'Músicas',
                                  style: headerStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              controller: _scrollController,
              body: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: x / 2),
                    child: ListView(
                      children: playlistContainers,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: x / 2),
                    child: ListView(
                      children: songContainers,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
