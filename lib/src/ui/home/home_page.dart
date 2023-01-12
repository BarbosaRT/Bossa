import 'package:bossa/src/color/color_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colorController = Modular.get<ColorController>();
    final accentColor = colorController.currentScheme.accentColor;
    return Scaffold(
      backgroundColor: accentColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Modular.to.pushNamed('/songAddPage');
            },
            child: Container(
                width: 200,
                height: 200,
                color: Colors.white,
                alignment: Alignment.center,
                child: const Text('Go to Next Page')),
          ),
        ],
      ),
    );
  }
}
