import 'package:asuka/asuka.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final backgroundColor = colorController.currentTheme.backgroundColor;
    final contrastColor = colorController.currentTheme.contrastColor;
    final contrastAccent = colorController.currentTheme.contrastAccent;

    TextStyle titleStyle = TextStyles().boldHeadline2.copyWith(
          color: contrastColor,
        );
    TextStyle authorStyle = TextStyles().headline3.copyWith(
          color: contrastAccent,
        );

    bool isHorizontal = size.width > size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: isHorizontal ? size.width * 0.5 : size.width,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
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
                  },
                );
              },
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: (isHorizontal
                                ? size.width * (1 - UIConsts.leftBarRatio)
                                : size.width) -
                            160,
                        height: 20,
                        child: TextStyles().getConstrainedTextByWidth(
                          textStyle: titleStyle,
                          text: widget.title,
                          textWidth: isHorizontal
                              ? size.width * (1 - UIConsts.leftBarRatio)
                              : size.width,
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
                ],
              ),
            ),
            //
            // Snackbar Button
            //
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
                  },
                );
              },
              child: SizedBox(
                width: UIConsts.iconSize * 1.25,
                height: UIConsts.iconSize * 1.25,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: contrastColor,
                    size: UIConsts.iconSize.toDouble(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
