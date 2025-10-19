import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bossa/src/color/color_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class WindowButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final WindowButtonColors buttonColors;
  const WindowButton(
      {required this.onTap,
      required this.icon,
      required this.buttonColors,
      super.key});

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 80,
          width: 50,
          decoration: BoxDecoration(
            color: isHovered
                ? widget.buttonColors.mouseOver
                : widget.buttonColors.mouseDown,
          ),
          child: Icon(
            widget.icon,
            color: isHovered
                ? widget.buttonColors.iconNormal
                : widget.buttonColors.iconMouseOver,
          ),
        ),
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final contrastColor = colorController.currentTheme.contrastColor;
    final accentColor = colorController.currentTheme.accentColor;
    //final backgroundColor = colorController.currentTheme.backgroundColor;

    final buttonColors = WindowButtonColors(
      iconNormal: contrastColor,
      mouseOver: accentColor,
      mouseDown: contrastColor,
      iconMouseOver: contrastColor,
      iconMouseDown: accentColor,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: contrastColor,
      iconMouseOver: Colors.white,
    );
    return Row(
      children: [
        Expanded(child: MoveWindow()),
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

// WindowTitleBarBox(
//               child: Row(
//                 children: [
//                   Expanded(child: MoveWindow()),
//                   MinimizeWindowButton(),
//                   MaximizeWindowButton(),
//                   CloseWindowButton(),
//                 ],
//               ),
//             ),
