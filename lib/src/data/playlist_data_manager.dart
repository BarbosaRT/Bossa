import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart' as sql;

class PlaylistDataManager {
  @visibleForTesting
  void deleteAll() async {
    var database = await dataManagerInstance.database();
    database.delete('playlists');
  }

  void addPlaylist(PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();
    database.insert('playlists', playlist.toSql(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  void deletePlaylist(PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();
    database.delete('playlists_songs',
        where: 'playlists_songs.idPlaylist = ?', whereArgs: [playlist.id]);
    database.delete('playlists',
        where: 'playlists.id = ?', whereArgs: [playlist.id]);
  }

  void editPlaylist(PlaylistModel editedPlaylist) async {
    var database = await dataManagerInstance.database();
    database.update('playlists', editedPlaylist.toSql(),
        where: 'playlists.id = ?', whereArgs: [editedPlaylist.id]);
  }

  Future<List<PlaylistModel>> loadPlaylists() async {
    var database = await dataManagerInstance.database();
    List<Map> playlistsFromQuery = await database.query('playlists');
    List<PlaylistModel> playlists = [];

    for (Map playlistFromQuery in playlistsFromQuery) {
      PlaylistModel playlist = PlaylistModel.fromMap(playlistFromQuery);
      playlist.songs = await _loadSongsFromPlaylist(playlist);
      playlists.add(playlist);
    }

    return playlists;
  }

  Future<List<SongModel>> _loadSongsFromPlaylist(PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();

    List<Map> songsFromPlaylist = await database.rawQuery("""
    SELECT s.id, s.title, s.icon, s.url, s.path from songs as s 
    JOIN playlists_songs as ps ON ps.idSong = s.id AND ps.idPlaylist = ${playlist.id}; 
    """);

    List<SongModel> output = [];
    for (Map result in songsFromPlaylist) {
      SongModel song = SongModel.fromMap(result);
      song.url = await SongUrlParser().parseSongUrlToInvidious(song.url);
      output.add(SongModel.fromMap(result));
    }
    return output;
  }

  void deleteFromPlaylist(SongModel song, PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();
    database.delete('playlists_songs',
        where: 'playlists_songs.idPlaylist = ? and playlists_songs.idSong = ?',
        whereArgs: [playlist.id, song.id]);
  }

  void appendToPlaylist(SongModel song, PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();
    var values = {'idPlaylist': playlist.id, 'idSong': song.id};
    database.insert('playlists_songs', values,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
}
