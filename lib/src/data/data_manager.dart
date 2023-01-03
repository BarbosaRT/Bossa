import 'dart:async';
import 'package:bossa/src/file/file_path.dart';
import 'package:sqflite/sqflite.dart' as sql;

DataManager dataManagerInstance = DataManager(filePath: FilePathImpl());

class DataManager {
  FilePath filePath;
  static const Duration _closeDatabaseDelay = Duration(milliseconds: 500);
  Timer closeDatabaseTimer = Timer(_closeDatabaseDelay, () {});
  sql.Database? _db;

  DataManager({required this.filePath});

  String get _databasePath {
    return '${filePath.getWorkingDirectory}/database.db';
  }

  static Future<void> createTables(sql.Database database) async {
    // dataManagerInstance.executeDatabaseCommand('PRAGMA encoding="UTF-8";');
    await database.execute("""CREATE TABLE IF NOT EXISTS songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text
    )
    """);
    await database.execute("""CREATE TABLE IF NOT EXISTS playlists(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text
    )
    """);
    await database.execute("""CREATE TABLE IF NOT EXISTS playlists_songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      idPlaylist integer NOT NULL,
      idSong integer NOT NULL,
      FOREIGN KEY(idPlaylist) REFERENCES playlists(id),
      FOREIGN KEY(idSong) REFERENCES songs(id)
    )
    """);
  }

  Future<sql.Database> database() async {
    if (_db != null) return _db!;
    _db = await sql.openDatabase(
      _databasePath,
      version: 1,
      onCreate: (sql.Database openDatabase, int version) async {
        await createTables(openDatabase);
      },
    );
    return _db!;
  }
}
