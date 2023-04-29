import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/playlist/add_to_playlist_page.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeUrlAddPage extends StatefulWidget {
  final String? url;
  final bool isSong;
  final bool? addToPlaylist;
  const YoutubeUrlAddPage(
      {super.key, required this.isSong, this.url, this.addToPlaylist});

  @override
  State<YoutubeUrlAddPage> createState() => _YoutubeUrlAddPageState();
}

class _YoutubeUrlAddPageState extends State<YoutubeUrlAddPage> {
  final urlTextController = TextEditingController();
  static double x = UIConsts.spacing;

  @override
  void initState() {
    super.initState();

    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (widget.url != null) {
      urlTextController.text = widget.url!;
    }
  }

  void addCommand(String value) async {
    final colorController = Modular.get<ColorController>();
    final snackbarColor = colorController.currentTheme.backgroundAccent;
    final contrastColor = colorController.currentTheme.contrastColor;

    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final parser = YoutubeParser(songDataManager: songDataManager);

    final textStyle = TextStyles().boldHeadline2.copyWith(color: contrastColor);

    String content = widget.isSong ? 'song'.i18n() : 'playlist';

    Asuka.showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor,
        duration: const Duration(days: 1),
        content: Text(
          '${"loading-content".i18n()} $content',
          style: textStyle,
        ),
      ),
    );
    SongModel? song;
    PlaylistModel? finalPlaylist;
    if (widget.isSong) {
      song = await parser.convertYoutubeSong(value);
      songDataManager.addSong(song);
    } else {
      var yt = YoutubeExplode();

      var playlist =
          await yt.playlists.get(YoutubeParser().parseYoutubePlaylist(value));

      final videoCount = playlist.videoCount == null ? 0 : playlist.videoCount!;
      yt.close();

      Stream<PlaylistModel> playlistStream =
          parser.convertYoutubePlaylist(value).asBroadcastStream();

      Asuka.hideCurrentSnackBar();
      Asuka.showSnackBar(
        SnackBar(
          backgroundColor: snackbarColor,
          duration: const Duration(days: 1),
          content: StreamBuilder<PlaylistModel>(
            stream: playlistStream,
            builder: (context, snapshot) {
              int downloaded =
                  snapshot.data != null ? snapshot.data!.songs.length : 0;
              final progress = ((downloaded / videoCount) * 100).toInt();
              return Text(
                '${"progress".i18n()} ($downloaded / $videoCount): $progress%',
                style: textStyle,
              );
            },
          ),
        ),
      );

      await for (var playlist in playlistStream) {
        finalPlaylist = playlist;
      }
      await playlistDataManager.addPlaylist(finalPlaylist!);
      finalPlaylist = await playlistDataManager.loadLastAddedPlaylist();
    }
    Asuka.hideCurrentSnackBar();
    Asuka.showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor,
        content: Text(
          '$content ${"sucessful-loading".i18n()}',
          style: textStyle,
        ),
      ),
    );
    if (widget.addToPlaylist == true && widget.isSong) {
      song = await songDataManager.loadLastAddedSong();
      Modular.to.push(
        MaterialPageRoute(
          builder: (context) => AddToPlaylistPage(
            song: song!,
          ),
        ),
      );
    } else {
      Modular.to.popUntil(ModalRoute.withName('/'));
      if (widget.isSong) {
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => SongAddPage(
              songToBeEdited: song,
            ),
          ),
        );
      } else {
        Modular.to.push(
          MaterialPageRoute(
            builder: (context) => PlaylistAddPage(
              playlistToBeEdited: finalPlaylist,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final accentColor = colorController.currentTheme.accentColor;

    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);
    TextStyle headerStyle =
        TextStyles().headline.copyWith(color: contrastColor);
    TextStyle buttonStyle =
        TextStyles().headline3.copyWith(color: contrastColor);

    String content = widget.isSong ? 'song'.i18n() : 'playlist';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor,
              backgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: x),
          child: ListView(
            children: [
              SizedBox(
                height: size.height / 3,
              ),
              SizedBox(
                width: size.width,
                child: Text(
                  '${"insert-url".i18n()} $content',
                  style: headerStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: size.width,
                height: x,
                child: TextField(
                  controller: urlTextController,
                  decoration: InputDecoration(
                    hintText: 'Url',
                    hintStyle: titleStyle,
                    isDense: true,
                    helperMaxLines: 1,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: titleStyle,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Modular.to.popUntil(ModalRoute.withName('/'));
                    },
                    child: Text(
                      'cancel'.i18n(),
                      style: buttonStyle,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      addCommand(urlTextController.text);
                    },
                    child: Text(
                      'add'.i18n(),
                      style: buttonStyle,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
