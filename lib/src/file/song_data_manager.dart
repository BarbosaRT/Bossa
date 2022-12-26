import 'package:bossa/src/file/file_path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bossa/models/song_model.dart';

class SongDataManager {
  FilePath filePath;
  SongDataManager({required this.filePath}) {
    init();
  }

  String get _databasePath {
    return '${filePath.getWorkingDirectory}/database.db';
  }

  void init() {
    _databaseHandler('PRAGMA encoding="UTF-8";');
    _databaseHandler('''CREATE TABLE IF NOT EXISTS songs (
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text
    )''');
  }

  void _databaseHandler(String command) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);
    database.execute(command);
  }

  void addSong(SongModel song) {
    init();
    _databaseHandler('INSERT INTO songs VALUES ${song.toSQL()};');
  }

  void removeSong(SongModel song) {
    init();
    _databaseHandler('DELETE FROM songs WHERE songs.id = ${song.id};');
  }

  Future<SongModel> loadSong(int id) async {
    var database = await databaseFactoryFfi.openDatabase(_databasePath);

    List<Map> results =
        await database.rawQuery('SELECT * FROM songs WHERE songs.id = $id');
    SongModel output = SongModel.fromMap(results[0]);

    database.close();
    return output;
  }
}
