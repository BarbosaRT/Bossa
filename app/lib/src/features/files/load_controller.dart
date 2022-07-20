import 'dart:convert';
import 'dart:io';
import 'package:bossa/src/features/path/path_controller.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

enum LoadStates {loading, idle, sucess, error}

class LoadNotifier extends ChangeNotifier {
  PathNotifier pathNotifier;
  List<List<dynamic>> _songs = [[]];
  List<List<dynamic>> get songs => _songs;

  LoadNotifier({required this.pathNotifier});

  void load() async {
    final dir = await pathNotifier.getDirectory();
    final file = File(dir.path);
    if (file.existsSync()){
      final csvFile = pathNotifier.file.openRead();
      final csvData = await csvFile
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(),)
          .toList();
      _songs = csvData;
    }
    else {
      file.writeAsString('');
    }
    notifyListeners();
  } 

  Future<List<List<dynamic>>> loadFile() async {
    List<List<dynamic>> output = [[]];
    final dir = await pathNotifier.getDirectory();
    final file = File(dir.path);

    if (file.existsSync()){
      final csvFile = file.openRead();
      final csvData = await csvFile
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(),)
          .toList();
      output = csvData;
      // print(csvData);
    }
    else {
      file.writeAsString('');
    }
    return output;
  }

  Future<List<List<dynamic>>> loadSongs() async {
    List<List<dynamic>> output = [[]];
    final docDir = await pathNotifier.getDocumentsDirectory();
    final dir = await pathNotifier.getDirectory();
    final file = File(dir.path);

    if (file.existsSync()){
      final csvFile = file.openRead();
      final csvData = await csvFile
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(),)
          .toList();
      for (List song in csvData){
        output.add([song[0], song[1], '${docDir.path}/${song[2]}', '${docDir.path}/${song[3]}']);
      }
    }
    else {
      file.writeAsString('');
    }
    return output;
  }
}