import 'package:asuka/asuka.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
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
      child: Container(
        width: size.width,
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
                        width: size.width - 160,
                        height: 20,
                        child: TextScroll(
                          widget.title,
                          mode: TextScrollMode.endless,
                          velocity:
                              const Velocity(pixelsPerSecond: Offset(100, 0)),
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
