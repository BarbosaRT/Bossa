import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  static double x = 30;

  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;

    final songDataManager = Modular.get<SongDataManager>();
    final playlistDataManager = Modular.get<PlaylistDataManager>();

    final headerStyle =
        TextStyles().boldHeadline.copyWith(color: contrastColor);
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: x / 2,
          ),
          Row(
            children: [
              SizedBox(
                width: x / 2,
              ),
              Text('Sua Biblioteca', style: headerStyle),
            ],
          ),
          // NestedScrollView(headerSliverBuilder: ((context, innerBoxIsScrolled) {

          // }), body: )
        ],
      ),
    );
  }
}
