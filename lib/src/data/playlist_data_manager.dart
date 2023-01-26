import 'package:flutter/widgets.dart';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';

enum PlaylistFilter { idAsc, idDesc, asc, desc }

class PlaylistDataManager {
  final DataManager localDataManagerInstance;
  PlaylistDataManager({
    required this.localDataManagerInstance,
  });

  @visibleForTesting
  void deleteAll() async {
    var database = await localDataManagerInstance.database();
    database.delete('playlists');
    database.delete('playlists_songs');
  }

  void addPlaylist(PlaylistModel playlist) async {
    var database = await localDataManagerInstance.database();
    database.rawInsert(
        'INSERT INTO playlists(title, icon) VALUES("${playlist.title}", "${playlist.icon}")');

    // Insert Songs into playlist
    var playlists = await loadPlaylists();
    for (SongModel song in playlist.songs) {
      appendToPlaylist(song, playlists[playlists.length - 1]);
    }
  }

  void deletePlaylist(PlaylistModel playlist) async {
    var database = await localDataManagerInstance.database();
    database.delete('playlists_songs',
        where: 'playlists_songs.idPlaylist = ?', whereArgs: [playlist.id]);
    database.delete('playlists',
        where: 'playlists.id = ?', whereArgs: [playlist.id]);
  }

  Future<void> editPlaylist(PlaylistModel editedPlaylist) async {
    var database = await localDataManagerInstance.database();

    database.update(
      'playlists',
      editedPlaylist.toSql(),
      where: 'playlists.id = ?',
      whereArgs: [editedPlaylist.id],
    );

    database.delete(
      'playlists_songs',
      where: 'playlists_songs.idPlaylist = ?',
      whereArgs: [editedPlaylist.id],
    );

    for (SongModel song in editedPlaylist.songs) {
      appendToPlaylist(song, editedPlaylist);
    }
  }

  Future<PlaylistModel> loadLastAddedPlaylist() async {
    var database = await localDataManagerInstance.database();
    List<Map<String, dynamic>> result = await database
        .rawQuery('SELECT * FROM playlists ORDER BY id DESC LIMIT 1');

    return PlaylistModel.fromMap(result[0]);
  }

  Future<List<PlaylistModel>> loadPlaylists(
      {PlaylistFilter filter = PlaylistFilter.idDesc}) async {
    var database = await localDataManagerInstance.database();
    List<Map> playlistsFromQuery = await database.query(
      'playlists',
      orderBy: _getOrderBy(filter),
    );
    List<PlaylistModel> playlists = [];

    for (Map playlistFromQuery in playlistsFromQuery) {
      PlaylistModel playlist = PlaylistModel.fromMap(playlistFromQuery);
      playlist.songs = await _loadSongsFromPlaylist(playlist);
      playlists.add(playlist);
    }

    return playlists;
  }

  String _getOrderBy(PlaylistFilter filter) {
    switch (filter) {
      case PlaylistFilter.idAsc:
        return 'id';
      case PlaylistFilter.idDesc:
        return 'id desc';
      case PlaylistFilter.asc:
        return 'title';
      case PlaylistFilter.desc:
        return 'title desc';
      default:
        return 'id desc';
    }
  }

  Future<List<PlaylistModel>> searchPlaylists(
      {required String searchQuery,
      PlaylistFilter filter = PlaylistFilter.idDesc}) async {
    var database = await localDataManagerInstance.database();
    List<Map<String, dynamic>> playlistsFromQuery = await database.query(
      'playlists',
      orderBy: _getOrderBy(filter),
      where: 'title like "${searchQuery.trim()}%"',
    );

    List<PlaylistModel> playlists = [];

    for (Map playlistFromQuery in playlistsFromQuery) {
      PlaylistModel playlist = PlaylistModel.fromMap(playlistFromQuery);
      playlist.songs = await _loadSongsFromPlaylist(playlist);
      playlists.add(playlist);
    }

    return playlists;
  }

  Future<List<SongModel>> _loadSongsFromPlaylist(PlaylistModel playlist) async {
    var database = await localDataManagerInstance.database();

    List<Map> songsFromPlaylist = await database.rawQuery("""
    SELECT s.id, s.title, s.icon, s.url, s.path, s.author from songs as s 
    JOIN playlists_songs as ps ON ps.idSong = s.id AND ps.idPlaylist = ${playlist.id}; 
    """);

    List<SongModel> output = [];
    for (Map result in songsFromPlaylist) {
      SongModel song = SongModel.fromMap(result);
      output.add(song);
    }
    return output;
  }

  void deleteFromPlaylist(SongModel song, PlaylistModel playlist) async {
    var database = await localDataManagerInstance.database();
    database.delete('playlists_songs',
        where: 'playlists_songs.idPlaylist = ? and playlists_songs.idSong = ?',
        whereArgs: [playlist.id, song.id]);
  }

  Future<void> appendToPlaylist(SongModel song, PlaylistModel playlist) async {
    var database = await localDataManagerInstance.database();
    await database.rawInsert(
        'INSERT INTO playlists_songs(idPlaylist, idSong) VALUES("${playlist.id}", "${song.id}")');
  }
}
