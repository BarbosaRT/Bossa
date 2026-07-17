import 'package:bossa/src/color/color_controller.dart';
import 'package:bossa/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A utility class for showing theme-aware snackbars using ScaffoldMessenger.
///
/// Usage examples:
///
/// // Simple message
/// ThemeAwareSnackbar.show(
///   context: context,
///   message: 'Operation completed successfully',
/// );
///
/// // With action button
/// ThemeAwareSnackbar.show(
///   context: context,
///   message: 'Update available',
///   action: SnackBarAction(
///     label: 'Download',
///     onPressed: () => launchUrl(updateUrl),
///   ),
/// );
///
/// // Custom container style
/// ThemeAwareSnackbar.showWithContainer(
///   context: context,
///   message: 'Backup saved successfully',
///   width: MediaQuery.of(context).size.width,
///   height: 80,
/// );
class ThemeAwareSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final colorController = Modular.get<ColorController>();
    final snackbarColor = colorController.currentTheme.backgroundAccent;
    final contrastColor = colorController.currentTheme.contrastColor;
    final textStyle = TextStyles().boldHeadline2.copyWith(color: contrastColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor,
        duration: duration,
        content: Text(
          message,
          style: textStyle,
        ),
        action: action,
      ),
    );
  }

  static void showCustom({
    required BuildContext context,
    required Widget content,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
  }) {
    final colorController = Modular.get<ColorController>();
    final snackbarColor =
        backgroundColor ?? colorController.currentTheme.backgroundAccent;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: snackbarColor,
        duration: duration,
        content: content,
      ),
    );
  }

  static void showWithContainer({
    required BuildContext context,
    required String message,
    required double width,
    double height = 50,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colorController = Modular.get<ColorController>();
    final backgroundAccent = colorController.currentTheme.backgroundAccent;
    final contrastColor = colorController.currentTheme.contrastColor;
    final textStyle = TextStyles().boldHeadline2.copyWith(color: contrastColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: backgroundAccent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                message,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
