import 'dart:async';
import 'dart:io';
import 'package:bossa/src/data/song_parser.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter/foundation.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';

enum SongDataManagerFilter { idDesc, idAsc, timesPlayedDesc, timesPlayedAsc }

class SongDataManager {
  final DataManager localDataManagerInstance;
  final DownloadService downloadService;

  SongDataManager(
      {required this.localDataManagerInstance, required this.downloadService});

  @visibleForTesting
  void deleteAll() async {
    var database = await localDataManagerInstance.database();
    database.delete('songs', where: 'id >= 0');
  }

  void addSong(SongModel song) async {
    var database = await localDataManagerInstance.database();
    await database.rawInsert(
        '''INSERT INTO songs(title, icon, url, path, author, timesPlayed) 
        VALUES("${song.title}","${song.icon}","${song.url}","${song.path}", "${song.author}", "${song.timesPlayed}")''');
  }

  Future<void> deleteFile(String path) async {
    try {
      await File(path).delete();
    } catch (e) {
      return;
    }
  }

  void removeSong(SongModel song) async {
    var database = await localDataManagerInstance.database();
    if (SongParser().isSongFromYoutube(song.url)) {
      deleteFile(song.path);
    }

    database.rawDelete(
        'DELETE FROM playlists_songs WHERE playlists_songs.idSong = ${song.id}');
    database.rawDelete('DELETE FROM songs WHERE songs.id = ${song.id}');
  }

  void editSong(SongModel editedSong) async {
    var database = await localDataManagerInstance.database();
    database.rawUpdate('''UPDATE songs SET title = "${editedSong.title}", 
        icon = "${editedSong.icon}", url = "${editedSong.url}", 
        path = "${editedSong.path}", author = "${editedSong.author}", timesPlayed = "${editedSong.timesPlayed}" 
        WHERE id = "${editedSong.id}"''');
  }

  Future<List<SongModel>> loadAllSongs(
      {SongDataManagerFilter filter = SongDataManagerFilter.idDesc}) async {
    var database = await localDataManagerInstance.database();
    List<Map<String, dynamic>> results =
        await database.query('songs', orderBy: _getOrderBy(filter));

    List<SongModel> output = [];
    for (Map<String, dynamic> result in results) {
      SongModel song = SongModel.fromMap(result);
      output.add(song);
    }
    return output;
  }

  Future<List<SongModel>> searchSongs(
      {required String searchQuery,
      SongDataManagerFilter filter = SongDataManagerFilter.idDesc}) async {
    var database = await localDataManagerInstance.database();
    List<Map<String, dynamic>> results = await database.query(
      'songs',
      orderBy: _getOrderBy(filter),
      where: 'title like "${searchQuery.trim()}%"',
    );

    List<SongModel> output = [];
    for (Map<String, dynamic> result in results) {
      SongModel song = SongModel.fromMap(result);
      output.add(song);
    }
    return output;
  }

  String _getOrderBy(SongDataManagerFilter filter) {
    switch (filter) {
      case SongDataManagerFilter.idAsc:
        return 'id';
      case SongDataManagerFilter.idDesc:
        return 'id desc';
      case SongDataManagerFilter.timesPlayedAsc:
        return 'timesPlayed';
      case SongDataManagerFilter.timesPlayedDesc:
        return 'timesPlayed desc';
      default:
        return 'id desc';
    }
  }

  Future<SongModel> loadLastAddedSong() async {
    var database = await localDataManagerInstance.database();
    List<Map<String, dynamic>> result =
        await database.rawQuery('SELECT * FROM songs ORDER BY id DESC LIMIT 1');

    SongModel output = SongModel.fromMap(result[0]);
    return output;
  }
}
