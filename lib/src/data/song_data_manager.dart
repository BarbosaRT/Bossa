import 'dart:async';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/song_url_parser.dart';

import 'package:flutter/foundation.dart';

class SongDataManager {
  @visibleForTesting
  void deleteAll() async {
    var database = await dataManagerInstance.database();
    database.delete('songs', where: 'id >= 0');
  }

  void addSong(SongModel song) async {
    song.url = SongUrlParser().parseSongUrlToSave(song.url);

    var database = await dataManagerInstance.database();
    database.rawInsert(
        'INSERT INTO songs(title, icon, url, path) VALUES("${song.title}","${song.icon}","${song.url}","${song.path}")');
  }

  void removeSong(SongModel song) async {
    var database = await dataManagerInstance.database();
    database.delete('playlists_songs',
        where: 'playlists_songs.idSong = ?', whereArgs: [song.id]);
    database.delete('songs', where: 'songs.id = ?', whereArgs: [song.id]);
  }

  void editSong(SongModel editedSong) async {
    var database = await dataManagerInstance.database();
    editedSong.url = SongUrlParser().parseSongUrlToSave(editedSong.url);
    database.rawUpdate(
        'UPDATE songs SET title = "${editedSong.title}", icon = "${editedSong.icon}", url = "${editedSong.url}", path = "${editedSong.path}" WHERE id = "${editedSong.id}"');
  }

  Future<List<SongModel>> loadAllSongs() async {
    var database = await dataManagerInstance.database();
    List<Map<String, dynamic>> results =
        await database.query('songs', orderBy: "id");

    List<SongModel> output = [];
    for (Map<String, dynamic> result in results) {
      SongModel song = SongModel.fromMap(result);
      song.url = await SongUrlParser().parseSongUrlToPlay(song.url);
      output.add(song);
    }
    return output;
  }
}
