import 'package:asuka/asuka.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/data/youtube_parser.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class YoutubeUrlAddPage extends StatefulWidget {
  final bool isSong;
  const YoutubeUrlAddPage({super.key, required this.isSong});

  @override
  State<YoutubeUrlAddPage> createState() => _YoutubeUrlAddPageState();
}

class _YoutubeUrlAddPageState extends State<YoutubeUrlAddPage> {
  final urlTextController = TextEditingController();
  static double x = 30;

  void addCommand(String value) async {
    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final parser = YoutubeParser(songDataManager: songDataManager);

    String content = widget.isSong ? 'música' : 'playlist';

    AsukaSnackbar.warning('Carregando a $content').show();
    if (widget.isSong) {
      SongModel song = await parser.convertYoutubeSong(value);
      songDataManager.addSong(song);
    } else {
      PlaylistModel playlist = await parser.convertYoutubePlaylist(value);
      playlistDataManager.addPlaylist(playlist);
    }

    AsukaSnackbar.success('A $content foi carregada com sucesso').show();
    Modular.to.pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final accentColor = colorController.currentScheme.accentColor;

    TextStyle titleStyle =
        TextStyles().headline2.copyWith(color: contrastColor);
    TextStyle headerStyle =
        TextStyles().headline.copyWith(color: contrastColor);
    TextStyle buttonStyle =
        TextStyles().headline3.copyWith(color: contrastColor);

    String content = widget.isSong ? 'música' : 'playlist';

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
                  'Insira a Url da $content',
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
                      Modular.to.pop();
                    },
                    child: Text(
                      'CANCELAR',
                      style: buttonStyle,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      addCommand(urlTextController.text);
                    },
                    child: Text(
                      'ADICIONAR',
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
