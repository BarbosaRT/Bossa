import 'dart:async';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/models/song_model.dart';
//import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter/foundation.dart';

class SongDataManager {
  @visibleForTesting
  void deleteAll() {
    dataManagerInstance.executeDatabaseCommand('DROP TABLE IF EXISTS songs;');
  }

  void addSong(SongModel song) async {
    // song.url = SongUrlParser().parseSongUrlToSave(song.url);
    dataManagerInstance.executeDatabaseCommand(
        'INSERT INTO songs (title, icon, url, path) VALUES ${song.toSQL()};');
  }

  void removeSong(SongModel song) async {
    //Remove from playlists
    // dataManagerInstance.executeDatabaseCommand(
    //     'DELETE FROM playlists_songs WHERE playlists_songs.idSongs = ${song.id};');
    dataManagerInstance.executeDatabaseCommand(
        'DELETE FROM songs WHERE songs.id = ${song.id};');
  }

  Future<List<SongModel>> loadSongs() async {
    List<Map> results =
        await dataManagerInstance.executeQuery('SELECT * FROM songs');

    List<SongModel> output = [];
    for (Map result in results) {
      SongModel song = SongModel.fromMap(result);
      // song.url = await SongUrlParser().parseSongUrlToInvidious(song.url);
      output.add(song);
    }
    return output;
  }
}
