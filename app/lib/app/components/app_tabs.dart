import 'package:flutter/material.dart';

class AppTabs extends StatelessWidget {
  final Color backgroundColor;
  final String text;


  const AppTabs({Key? key, required this.backgroundColor, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(10),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 0),
            )
          ]),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
