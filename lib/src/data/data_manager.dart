import 'dart:async';
import 'package:bossa/src/file/file_path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DataManager dataManagerInstance = DataManager(filePath: FilePathImpl());

class DataManager {
  FilePath filePath;
  static const Duration _closeDatabaseDelay = Duration(milliseconds: 500);
  Timer closeDatabaseTimer = Timer(_closeDatabaseDelay, () {});
  DataManager({required this.filePath}) {
    init();
  }

  String get _databasePath {
    return '${filePath.getWorkingDirectory}/database.db';
  }

  void init() {
    dataManagerInstance.executeDatabaseCommand('PRAGMA encoding="UTF-8";');
    dataManagerInstance
        .executeDatabaseCommand('''CREATE TABLE IF NOT EXISTS songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text
    );''');
    executeDatabaseCommand('''CREATE TABLE IF NOT EXISTS playlists(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text
    );''');
    executeDatabaseCommand('''CREATE TABLE IF NOT EXISTS playlists_songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      idPlaylist integer NOT NULL,
      idSong integer NOT NULL, 
      FOREIGN KEY(idPlaylist) REFERENCES playlists(id),
      FOREIGN KEY(idSong) REFERENCES songs(id) 
    );''');
  }

  Future<List<Map>> executeQuery(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    List<Map> results = await database.rawQuery(command);

    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(_closeDatabaseDelay, () {
      database.close();
    });
    return results;
  }

  void executeDatabaseCommand(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    database.execute(command);
    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(_closeDatabaseDelay, () {
      database.close();
    });
  }
}
