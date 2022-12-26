import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class FilePath {
  String get getWorkingDirectory => '${getDocumentsDirectory()}/bossa';
  Future<String> getDocumentsDirectory();
}

class FilePathImpl extends FilePath {
  @override
  Future<String> getDocumentsDirectory() async {
    Directory output = await getApplicationDocumentsDirectory();
    return output.path;
  }
}
