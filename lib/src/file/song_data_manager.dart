import 'dart:async';

import 'package:bossa/src/file/file_path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bossa/models/song_model.dart';

class SongDataManager {
  FilePath filePath;
  static const Duration closeDatabaseDelay = Duration(milliseconds: 500);
  Timer closeDatabaseTimer = Timer(closeDatabaseDelay, () {});

  SongDataManager({required this.filePath}) {
    init();
  }

  String get _databasePath {
    return '${filePath.getWorkingDirectory}/database.db';
  }

  void init() async {
    _databaseHandler('PRAGMA encoding="UTF-8";');
    _databaseHandler('DELETE TABLE songs;');
    _databaseHandler('''CREATE TABLE IF NOT EXISTS songs (
      id integer unsigned NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text
    )''');
  }

  void _databaseHandler(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    database.execute(command);
    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(closeDatabaseDelay, () {
      database.close();
    });
  }

  void addSong(SongModel song) async {
    _databaseHandler(
        'INSERT INTO songs (title, icon, url, path) VALUES ${song.toSQL()};');
  }

  void removeSong(SongModel song) async {
    _databaseHandler('DELETE FROM songs WHERE songs.id = ${song.id};');
  }

  Future<SongModel?> loadSong(int id) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);

    List<Map> results =
        await database.rawQuery('SELECT * FROM songs WHERE songs.id = $id');
    if (results.isEmpty) {
      return null;
    }
    SongModel output = SongModel.fromMap(results[0]);

    closeDatabaseTimer.cancel();
    closeDatabaseTimer = Timer(closeDatabaseDelay, () {
      database.close();
    });
    return output;
  }
}
