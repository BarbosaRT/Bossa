import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_url_parser.dart';
import 'package:flutter/widgets.dart';

class PlaylistDataManager {
  @visibleForTesting
  void deleteAll() async {
    var database = await dataManagerInstance.database();
    database.delete('playlists');
    database.delete('playlists_songs');
  }

  void addPlaylist(PlaylistModel playlist) async {
    var database = await dataManagerInstance.database();
    database.rawInsert(
        'INSERT INTO playlists(title, icon) VALUES("${playlist.title}", "${playlist.icon}")');

    // Insert Songs into playlist
    var playlists = await loadPlaylists();
    for (SongModel song in playlist.songs) {
      appendToPlaylist(song, playlists[playlists.length - 1]);
    }
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

  Future<PlaylistModel> loadLastAddedPlaylist() async {
    var database = await dataManagerInstance.database();
    List<Map<String, dynamic>> result = await database
        .rawQuery('SELECT * FROM playlists ORDER BY id DESC LIMIT 1');

    return PlaylistModel.fromMap(result[0]);
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
      song.url = await SongUrlParser().parseSongUrlToPlay(song.url);
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
    await database.transaction((transaction) async {
      await transaction.insert('playlists_songs', values);
    });
  }
}
