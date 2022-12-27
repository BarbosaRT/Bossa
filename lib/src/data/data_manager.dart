import 'dart:async';

import 'package:bossa/src/file/file_path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DataManager dataManagerInstance = DataManager(filePath: FilePathImpl());

class DataManager {
  FilePath filePath;
  static const Duration closeDatabaseDelay = Duration(milliseconds: 690);
  Timer closeDatabaseTimer = Timer(closeDatabaseDelay, () {});
  DataManager({required this.filePath});

  String get _databasePath {
    return '${filePath.getWorkingDirectory}/database.db';
  }

  Future<List<Map>> databaseQueryHandler(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    List<Map> results = await database.rawQuery(command);

    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(closeDatabaseDelay, () {
      database.close();
    });
    return results;
  }

  void databaseHandler(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    database.execute(command);
    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(closeDatabaseDelay, () {
      database.close();
    });
  }
}
