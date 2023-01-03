import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class FilePath {
  Future<String> getWorkingDirectory() async {
    String workingDirectory = await getWorkingDirectory();
    return '$workingDirectory/bossa';
  }

  Future<String> getDocumentsDirectory() async {
    throw Exception('Function getDocumentsDirectory() not implemented');
  }
}

class FilePathImpl extends FilePath {
  String _aplicationDocumentsDirectory = '';
  @override
  Future<String> getDocumentsDirectory() async {
    if (_aplicationDocumentsDirectory.isEmpty) {
      Directory output = await getApplicationDocumentsDirectory();
      _aplicationDocumentsDirectory = output.path;
    }
    return _aplicationDocumentsDirectory;
  }
}
