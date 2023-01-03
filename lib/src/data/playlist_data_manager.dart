import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_url_parser.dart';

// class PlaylistDataManager {
//   void deletePlaylist(PlaylistModel playlist) {
//     dataManagerInstance.executeDatabaseCommand(
//         'DELETE FROM playlists_songs WHERE playlist_songs.idPlaylist = ${playlist.id}');
//   }

//   void removeFromPlaylist(SongModel song, PlaylistModel playlist) {
//     dataManagerInstance.executeDatabaseCommand(
//         'INSERT INTO playlists_songs (idPlaylist, idSong) VALUES (${song.id}, ${playlist.id});');
//   }

//   void addToPlaylist(SongModel song, PlaylistModel playlist) {
//     dataManagerInstance.executeDatabaseCommand(
//         'INSERT INTO playlists_songs (idPlaylist, idSong) VALUES (${song.id}, ${playlist.id});');
//   }

//   Future<List<SongModel>> _loadSongsFromPlaylist(PlaylistModel playlist) async {
//     List<Map> songsFromPlaylist = await dataManagerInstance.executeQuery("""
//     SELECT s.id, s.title, s.icon, s.url, s.path from songs as s 
//     JOIN playlists_songs as ps ON ps.idSong = s.id
//     JOIN playlists as p ON ps.idPlaylist = ${playlist.id}; 
//     """);

//     List<SongModel> output = [];
//     for (Map result in songsFromPlaylist) {
//       SongModel song = SongModel.fromMap(result);
//       song.url = await SongUrlParser().parseSongUrlToInvidious(song.url);
//       output.add(SongModel.fromMap(result));
//     }
//     return output;
//   }

//   Future<List<PlaylistModel>> loadPlaylists() async {
//     List<Map> playlistsFromQuery =
//         await dataManagerInstance.executeQuery('SELECT * FROM playlists');
//     List<PlaylistModel> playlists = [];

//     for (Map playlistFromQuery in playlistsFromQuery) {
//       PlaylistModel playlist = PlaylistModel.fromMap(playlistFromQuery);
//       playlist.songs = await _loadSongsFromPlaylist(playlist);
//       playlists.add(playlist);
//     }

//     return playlists;
//   }
// }
