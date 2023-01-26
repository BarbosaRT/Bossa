import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterWidget extends StatefulWidget {
  final bool isSong;
  final void Function(dynamic) filterCallback;
  final void Function(bool) gridCallback;
  final bool enableDropbutton;
  const FilterWidget(
      {super.key,
      required this.isSong,
      required this.filterCallback,
      required this.gridCallback,
      this.enableDropbutton = true});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final iconSize = UIConsts.iconSize.toDouble();

  bool gridEnabled = false;

  SongFilter _songFilter = SongFilter.idDesc;
  PlaylistFilter _playlistFilter = PlaylistFilter.idDesc;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundAccent = colorController.currentScheme.backgroundAccent;

    final dropdownStyle = TextStyles().headline3.copyWith(color: contrastColor);

    final songItems = [
      DropdownMenuItem(
        value: SongFilter.idDesc,
        child: Text(
          'Recem Adicionados',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: SongFilter.idAsc,
        child: Text(
          'Mais antigos',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: SongFilter.timesPlayedAsc,
        child: Text(
          'Menos ouvidos',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: SongFilter.timesPlayedDesc,
        child: Text(
          'Mais ouvidos',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: SongFilter.asc,
        child: Text(
          'Ordem alfabetica, crescente',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: SongFilter.desc,
        child: Text(
          'Ordem alfabetica, decrescente',
          style: dropdownStyle,
        ),
      ),
    ];

    final playlistItems = [
      DropdownMenuItem(
        value: PlaylistFilter.idDesc,
        child: Text(
          'Recem Adicionados',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: PlaylistFilter.idAsc,
        child: Text(
          'Mais antigos',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: PlaylistFilter.asc,
        child: Text(
          'Ordem alfabetica, crescente',
          style: dropdownStyle,
        ),
      ),
      DropdownMenuItem(
        value: PlaylistFilter.desc,
        child: Text(
          'Ordem alfabetica, decrescente',
          style: dropdownStyle,
        ),
      ),
    ];

    return SizedBox(
      width: size.width - UIConsts.spacing * 1.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.enableDropbutton
              ? DropdownButton(
                  value: widget.isSong ? _songFilter : _playlistFilter,
                  dropdownColor: backgroundAccent,
                  items: widget.isSong ? songItems : playlistItems,
                  onChanged: (v) {
                    if (v == null) {
                      return;
                    }
                    if (widget.isSong) {
                      _songFilter = v as SongFilter;
                      widget.filterCallback(_songFilter);
                      return;
                    }
                    _playlistFilter = v as PlaylistFilter;
                    widget.filterCallback(_playlistFilter);
                  },
                )
              : const Spacer(),
          GestureDetector(
            onTap: () {
              gridEnabled = !gridEnabled;
              widget.gridCallback(gridEnabled);
              if (mounted) {
                setState(() {});
              }
            },
            child: SizedBox(
              width: iconSize * 2,
              height: iconSize * 1.5,
              child: Center(
                child: FaIcon(
                  gridEnabled
                      ? FontAwesomeIcons.gripVertical
                      : FontAwesomeIcons.bars,
                  size: iconSize,
                  color: contrastColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
