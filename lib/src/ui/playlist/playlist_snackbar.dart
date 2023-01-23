import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/home/components/home_widget.dart';
import 'package:bossa/src/ui/home/home_page.dart';
import 'package:bossa/src/ui/playlist/playlist_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlaylistSnackbar extends StatefulWidget {
  final PlaylistModel playlist;
  const PlaylistSnackbar({super.key, required this.playlist});

  @override
  State<PlaylistSnackbar> createState() => _PlaylistSnackbarState();
}

class _PlaylistSnackbarState extends State<PlaylistSnackbar> {
  double iconSize = UIConsts.iconSize.toDouble();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;

    final playlistDataManager = Modular.get<PlaylistDataManager>();
    final homeController = Modular.get<HomeController>();

    final buttonStyle =
        TextStyles().boldHeadline2.copyWith(color: contrastColor);
    return DetailContainer(
      icon: widget.playlist.icon,
      title: widget.playlist.title,
      actions: [
        SizedBox(
          width: size.width,
          height: 30,
          child: GestureDetector(
            onTap: () {
              playlistDataManager.deletePlaylist(widget.playlist);
              homeController.changeCurrentPage(Pages.home);
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
              Text('Remover ', style: buttonStyle),
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
                  builder: (context) => PlaylistAddPage(
                    playlistToBeEdited: widget.playlist,
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
              Text('Editar ', style: buttonStyle),
            ]),
          ),
        ),
      ],
    );
  }
}
