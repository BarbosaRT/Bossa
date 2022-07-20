import 'dart:io';
import 'dart:math';
import 'package:bossa/src/features/files/load_controller.dart';
import 'package:bossa/src/features/path/path_controller.dart';
import 'package:csv/csv.dart';
import 'package:bossa/src/core/models/song_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class SaveNotifier extends ChangeNotifier {
  SongModel song = SongModel();
  final Random _random = Random(69);
  bool _canSave = false;
  bool get canSave => _canSave;

  PathNotifier pathNotifier;
  LoadNotifier loadNotifier;

  SaveNotifier({required this.pathNotifier, required this.loadNotifier});

  void save(){
    _canSave = song.isFilled();
    if (_canSave){
      saveFile();
    }
  }

  void saveFile() async {
    final dir = await pathNotifier.getDirectory();
    File file = File(dir.path);
    
    List<List<dynamic>> data = await loadNotifier.loadFile();
    data.add(song.toList());
    String csvData = const ListToCsvConverter().convert(data);
    file.writeAsString(csvData);
    song = SongModel();
    notifyListeners();
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final path = await pathNotifier.getDocumentsDirectory();
    File newFile = File('${path.path}/${file.name}');
    if (newFile.existsSync()){
      String name = file.name.split('.')[0];
      String fileExtension = file.name.split('.')[1];
      newFile = File('${path.path}/$name${_random.nextInt(1000)}.$fileExtension');
    }
    return File(file.path!).copy(newFile.path);
  }
}