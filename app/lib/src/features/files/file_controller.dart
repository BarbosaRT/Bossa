import 'dart:io';

import 'package:bossa/src/core/models/song_model.dart';
import 'package:bossa/src/features/files/save_controller.dart';
import 'package:bossa/src/features/path/path_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileNotifier extends ChangeNotifier {
  PathNotifier pathNotifier;
  SaveNotifier saveNotifier;

  SongModel _songModel = SongModel();
  SongModel get songModel => _songModel;

  String _iconPath = '';
  String get iconPath => _iconPath;

  FileNotifier({required this.pathNotifier, required this.saveNotifier});

  void save(){
    if (songModel.isFilled()) {
      saveNotifier.song = songModel;
      saveNotifier.save();
      _songModel = SongModel();
      _iconPath = '';
      notifyListeners();
    }
  }

  void audioSave() async {
    final newFile = await selectFile(FileType.audio);
    if (newFile == null) {
      return;
    }
    final splittedPath = newFile.path.split('/');
    _songModel.audio = splittedPath[splittedPath.length - 1];
    notifyListeners();
  }

  void iconSave() async {
    final newFile = await selectFile(FileType.image);
    if (newFile == null) {
      return;
    }
    _iconPath = newFile.path;
    final splittedPath = newFile.path.split('/');
    _songModel.icon = splittedPath[splittedPath.length - 1];
    notifyListeners();
  }

  void titleSave(String title){
    _songModel.title = title;
    notifyListeners();
  }

  void authorSave(String author){
    _songModel.author = author;
    notifyListeners();
  }

  Future<File?> selectFile(FileType fileType) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: fileType);
    if (result == null) {
      return null;
    }
    final file = result.files.first;
    final newFile = await saveNotifier.saveFilePermanently(file);
    return newFile;
  }
}