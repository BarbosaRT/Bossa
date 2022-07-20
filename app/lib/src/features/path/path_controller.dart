import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum PathStates {sucess, error, idle, waiting}

class PathNotifier extends ChangeNotifier{
  Directory _documentsDirectory = Directory('');
  Directory get documentsDirectory => _documentsDirectory;

  Directory get directory => Directory('$_documentsDirectory/songs.csv');
  File get file => File('$_documentsDirectory/songs.csv');

  PathStates _state = PathStates.idle;
  PathStates get state => _state;

  void localPath() async {
    _state = PathStates.waiting; 
    notifyListeners();
    try{
      _documentsDirectory = await getApplicationDocumentsDirectory();
      _state = PathStates.sucess; 
      notifyListeners();
    }catch(e){
      _state = PathStates.error;
      notifyListeners();
    }
  }

  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> getDirectory() async {
    // Certo
    Directory output = await getApplicationDocumentsDirectory();
    return Directory('${output.path}/songs.csv');
  }
}