import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/components/detail_container.dart';
import 'package:bossa/src/ui/playlist/add_to_playlist_page.dart';
import 'package:bossa/src/ui/song/song_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

class SongSnackbar extends StatefulWidget {
  final SongModel song;
  final void Function()? callback;
  const SongSnackbar({super.key, required this.song, this.callback});

  @override
  State<SongSnackbar> createState() => _SongSnackbarState();
}

class _SongSnackbarState extends State<SongSnackbar> {
  double iconSize = UIConsts.iconSize.toDouble();
  bool canTapOffline = true;

  @override
  void initState() {
    super.initState();
    final colorController = Modular.get<ColorController>();
    colorController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;

    final songDataManager = Modular.get<SongDataManager>();

    final buttonStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);
    final key = GlobalKey<DetailContainerState>();

    return DetailContainer(
      title: widget.song.title,
      icon: widget.song.icon,
      key: key,
      actions: [
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () {
              key.currentState?.pop();
              songDataManager.removeSong(widget.song);
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
              Text('remove'.i18n(), style: buttonStyle),
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
                    songToBeEdited: widget.song,
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
              Text('edit'.i18n(), style: buttonStyle),
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
                  builder: (context) => AddToPlaylistPage(
                    song: widget.song,
                  ),
                ),
              );
            },
            child: Row(children: [
              FaIcon(
                FontAwesomeIcons.circlePlus,
                size: iconSize,
                color: contrastColor,
              ),
              SizedBox(
                width: iconSize / 2,
              ),
              Text('add-to-playlist'.i18n(), style: buttonStyle),
            ]),
          ),
        ),
      ],
    );
  }
}
