import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class FilePath {
  String parseToWorkingDirectory(String input) {
    return '$input/bossa';
  }

  Future<String> getDocumentsDirectory();
}

class FilePathImpl extends FilePath {
  String _aplicationDocumentsDirectory = '';

  @override
  Future<String> getDocumentsDirectory() async {
    if (_aplicationDocumentsDirectory.isEmpty) {
      Directory output = await getApplicationDocumentsDirectory();
      _aplicationDocumentsDirectory = parseToWorkingDirectory(output.path);
    }
    return _aplicationDocumentsDirectory;
  }
}
