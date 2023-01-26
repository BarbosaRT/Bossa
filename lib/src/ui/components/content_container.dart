import 'package:asuka/asuka.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ContentContainer extends StatefulWidget {
  final Widget detailContainer;
  final String icon;
  final String? title;
  final String? author;
  final double imagesSize;
  final double textWidth;
  final void Function() onTap;

  const ContentContainer({
    super.key,
    required this.icon,
    required this.detailContainer,
    required this.onTap,
    this.title,
    this.author,
    this.imagesSize = 100,
    this.textWidth = 190,
  });

  @override
  State<ContentContainer> createState() => _ContentContainerState();
}

class _ContentContainerState extends State<ContentContainer> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();

  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final contrastAccent = colorController.currentScheme.contrastAccent;
    final textStyle = TextStyles().boldHeadline2.copyWith(color: contrastColor);
    final authorStyle = TextStyles().headline3.copyWith(color: contrastAccent);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        Asuka.showModalBottomSheet(
          backgroundColor: Colors.transparent,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(
            image: ImageParser.getImageProviderFromString(
              widget.icon,
            ),
            fit: BoxFit.cover,
            alignment: FractionalOffset.center,
            width: widget.imagesSize,
            height: widget.imagesSize,
          ),
          widget.title != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextStyles().getConstrainedTextByWidth(
                      textStyle: textStyle,
                      text: widget.title!,
                      textWidth: widget.textWidth,
                    ),
                    widget.author != null
                        ? Text(
                            widget.author!,
                            style: authorStyle,
                            textAlign: TextAlign.center,
                          )
                        : Container(),
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
