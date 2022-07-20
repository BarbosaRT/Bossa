import 'package:bossa/src/features/theming/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeNotifier>();
    
    Color backgroundColor = themeController.themeData.backgroundColor;
    Color? iconColor = themeController.textTheme.headline2!.color;
    
    return Container(
      color: backgroundColor,
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            size: 30,
            color: iconColor,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, '/file');
                },
                icon: Icon(
                  Icons.add,
                  size: 30,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, '/settings');
                },
                icon: Icon(
                  Icons.settings,
                  size: 30,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}