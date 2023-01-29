import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:bossa/src/styles/ui_consts.dart';
import 'package:bossa/src/ui/image/image_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

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

  void pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final backgroundColor = colorController.currentTheme.backgroundColor;
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
                child: TextStyles().getConstrainedTextByWidth(
                  textStyle: titleStyle,
                  text: widget.title,
                  textWidth: size.width,
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
