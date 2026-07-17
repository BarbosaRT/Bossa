import 'dart:async';
import 'package:bossa/src/file/file_path.dart';
import 'package:sqflite/sqflite.dart' as sql;

DataManager dataManagerInstance = DataManager(filePath: FilePathImpl());
DataManager testDataManagerInstance = DataManager(
    filePath: FilePathImpl(),
    databasePath: '/test.db',
    databaseName: 'test.db');

class DataManager {
  FilePath filePath;
  static const Duration _closeDatabaseDelay = Duration(milliseconds: 500);
  Timer closeDatabaseTimer = Timer(_closeDatabaseDelay, () {});
  sql.Database? _db;
  String databasePath = '';
  String databaseName = 'database.db';

  DataManager(
      {required this.filePath,
      this.databasePath = '/database.db',
      this.databaseName = 'database.db'});

  Future<String> getDatabasePath() async {
    final workingDirectory = await filePath.getDocumentsDirectory();
    return '$workingDirectory/$databaseName';
  }

  Future<void> createTables(sql.Database database) async {
    await database.execute('PRAGMA encoding="UTF-8";');
    await database.execute("""CREATE TABLE IF NOT EXISTS songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text,
      author text,
      timesPlayed integer NOT NULL DEFAULT 0
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
    final databasePath = await getDatabasePath();
    _db = await sql.openDatabase(
      databasePath,
      version: 1,
      onCreate: (sql.Database openDatabase, int version) async {
        await createTables(openDatabase);
      },
    );
    return _db!;
  }

  Future<sql.Database> reloadDatabase() async {
    final databasePath = await getDatabasePath();
    _db = await sql.openDatabase(
      databasePath,
      version: 1,
      onCreate: (sql.Database openDatabase, int version) async {
        await createTables(openDatabase);
      },
    );
    return _db!;
  }
}
