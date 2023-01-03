import 'dart:async';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SongDataManager {
  @visibleForTesting
  void deleteAll() async {
    var database = await dataManagerInstance.database();
    database.delete('songs', where: 'id >= 0');
  }

  void addSong(SongModel song) async {
    song.url = SongUrlParser().parseSongUrlToSave(song.url);

    var database = await dataManagerInstance.database();
    database.insert('songs', song.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  void removeSong(SongModel song) async {
    var database = await dataManagerInstance.database();
    database.delete('playlist_songs',
        where: 'playlists_songs.idSongs = ?', whereArgs: [song.id]);
    database.delete('songs', where: 'songs.id = ?', whereArgs: [song.id]);
  }

  Future<List<SongModel>> loadAllSongs() async {
    var database = await dataManagerInstance.database();
    List<Map<String, dynamic>> results =
        await database.query('songs', orderBy: "id");

    List<SongModel> output = [];
    for (Map<String, dynamic> result in results) {
      SongModel song = SongModel.fromMap(result);
      song.url = await SongUrlParser().parseSongUrlToInvidious(song.url);
      output.add(song);
    }
    return output;
  }
}
