import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class FilePath {
  String parseToWorkingDirectory(String input) {
    return '$input/bossa';
  }

  String parseToExternalDirectory(String input) {
    return '$input/Bossa';
  }

  Future<String> getDocumentsDirectory();
}

class FilePathImpl extends FilePath {
  String _aplicationDocumentsDirectory = '';
  String _externalDocumentsDirectory = '';

  @override
  Future<String> getDocumentsDirectory() async {
    if (_aplicationDocumentsDirectory.isEmpty) {
      Directory output = await getApplicationDocumentsDirectory();
      _aplicationDocumentsDirectory = parseToWorkingDirectory(output.path);
    }
    return _aplicationDocumentsDirectory;
  }

  Future<String> getExternalDirectory() async {
    if (_externalDocumentsDirectory.isEmpty && Platform.isAndroid) {
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      String output = '';
      if (directory != null) {
        output = directory.path;
      } else {
        directory = Directory('/storage/emulated/0/');
        await directory.create();
        output = directory.path;
      }
      _externalDocumentsDirectory = parseToExternalDirectory(output);
    }
    return _externalDocumentsDirectory;
  }
}
