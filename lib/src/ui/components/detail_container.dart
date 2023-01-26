import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:text_scroll/text_scroll.dart';

class DetailContainer extends StatefulWidget {
  final String icon;
  final String title;
  final List<Widget> actions;
  const DetailContainer({
    Key? key,
    required this.icon,
    required this.title,
    required this.actions,
  }) : super(key: key);

  @override
  State<DetailContainer> createState() => DetailContainerState();
}

class DetailContainerState extends State<DetailContainer> {
  static double x = UIConsts.spacing;
  double iconSize = UIConsts.iconSize.toDouble();
  double imagesSize = 100;

  void pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentScheme.contrastColor;
    final backgroundColor = colorController.currentScheme.backgroundColor;
    final titleStyle = TextStyles().headline.copyWith(color: contrastColor);

    final height = size.height / 2;
    const textHeight = 50;

    return Container(
      height: height,
      width: size.width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: x),
        child: Column(
          children: [
            SizedBox(
              height: UIConsts.spacing,
            ),
            Container(
              width: imagesSize,
              height: imagesSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ImageParser.getImageProviderFromString(
                    widget.icon,
                  ),
                  fit: BoxFit.cover,
                  alignment: FractionalOffset.center,
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: textHeight.toDouble(),
              child: Center(
                child: TextScroll(
                  widget.title,
                  mode: TextScrollMode.endless,
                  velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
                  delayBefore: const Duration(seconds: 10),
                  pauseBetween: const Duration(seconds: 5),
                  style: titleStyle,
                  textAlign: TextAlign.center,
                  selectable: true,
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: height - textHeight - imagesSize - UIConsts.spacing,
              child: ListView.builder(
                itemCount: widget.actions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: widget.actions[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}