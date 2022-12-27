import 'dart:async';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter/foundation.dart';

class SongDataManager {
  SongDataManager() {
    init();
  }

  @visibleForTesting
  void deleteAll() {
    dataManagerInstance.databaseHandler('DROP TABLE IF EXISTS songs;');
  }

  void init() async {
    dataManagerInstance.databaseHandler('PRAGMA encoding="UTF-8";');
    dataManagerInstance.databaseHandler('''CREATE TABLE IF NOT EXISTS songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text,
      url text,
      path text
    );''');
  }

  void addSong(SongModel song) async {
    song.url = SongUrlParser().parseSongUrlToSave(song.url);
    dataManagerInstance.databaseHandler(
        'INSERT INTO songs (title, icon, url, path) VALUES ${song.toSQL()};');
  }

  void removeSong(SongModel song) async {
    dataManagerInstance
        .databaseHandler('DELETE FROM songs WHERE songs.id = ${song.id};');
  }

  Future<List<SongModel>> loadSongs() async {
    List<Map> results =
        await dataManagerInstance.databaseQueryHandler('SELECT * FROM songs');

    List<SongModel> output = [];
    for (Map result in results) {
      SongModel song = SongModel.fromMap(result);
      song.url = await SongUrlParser().parseSongUrlToInvidious(song.url);
      output.add(SongModel.fromMap(result));
    }
    return output;
  }
}
