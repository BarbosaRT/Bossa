import 'dart:convert';
import 'dart:io';

import 'package:bossa/app/pages/home_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeController extends StatefulWidget {
  Directory dir = Directory('');
  String screen = SelectedScreen.modern;
  HomeController({Key? key}) : super(key: key);

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  HomePage homePage = HomePage();
  List songs = [];
  late File jsonFile;
  String fileName = "songs.json";

  readData() {
    List<dynamic> json = jsonDecode(jsonFile.readAsStringSync());

    for (int ji = 0; ji < json.length; ji++) {
      var song = json[ji];
      if (ji > 0) {
        List<String> file = song
            .toString()
            .replaceAll('\\', '')
            .replaceAll('"{', '{')
            .split('},{');
        //print('File: $file ${file.length} ${file[0]}');
        songs.add(jsonDecode(file[0]));
      } else {
        songs.add(song);
      }
    }
    //print(songs);
    homePage.songs = songs;
  }

  @override
  void initState() {
    super.initState();
    // widget.songController.readData(context);
    //print("$fileExists ${widget.dir.path}/$fileName");
    homePage.selectedScreen = widget.screen;
    if (widget.dir.path != '') {
      jsonFile = File("${widget.dir.path}/$fileName");
      if (jsonFile.existsSync()) {
        readData();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return homePage;
  }
}
