import 'dart:io';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/models/song_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('PlaylistDataManager', () {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final playlistDataManager = PlaylistDataManager();
    final songDataManager = SongDataManager();
    final playlist1 =
        PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);
    final song1 = SongModel(
        id: 1,
        title: 'Song 1',
        icon: 'icon1',
        url: 'https://youtu.be/NgYoUsdETRw',
        path: 'path1');

    test('test if creates playlists', () async {
      playlistDataManager.deleteAll();
      List<PlaylistModel> loadedPlaylists1 =
          await playlistDataManager.loadPlaylists();
      playlistDataManager.addPlaylist(playlist1);
      List<PlaylistModel> loadedPlaylists2 =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists1.length + 1, loadedPlaylists2.length);
    });

    test('test if loads Playlists', () async {
      playlistDataManager.addPlaylist(playlist1);
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists, isNotNull);
      expect(loadedPlaylists.isEmpty, false);
    });

    test('test if adds song to playlist', () async {
      playlistDataManager.deleteAll();
      songDataManager.deleteAll();

      playlistDataManager.addPlaylist(playlist1);
      songDataManager.addSong(song1);

      playlistDataManager.appendToPlaylist(song1, playlist1);
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists[0].songs[0], song1);
    });

    test('test if loadPlaylists returns a empty list when list is empty',
        () async {
      playlistDataManager.deleteAll();
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists, []);
    });

    test('test if removes song from playlist', () async {
      playlistDataManager.deleteAll();
      songDataManager.deleteAll();

      playlistDataManager.addPlaylist(playlist1);
      songDataManager.addSong(song1);

      playlistDataManager.appendToPlaylist(song1, playlist1);
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();

      playlistDataManager.deleteFromPlaylist(song1, playlist1);
      List<PlaylistModel> loadedPlaylists2 =
          await playlistDataManager.loadPlaylists();

      expect(loadedPlaylists2.length, loadedPlaylists.length - 1);
      expect(loadedPlaylists2[0].songs[0], []);
    });

    test('test if deletePlaylist delete a playlist', () {
      playlistDataManager.deletePlaylist(playlist1);
    });
  });
}
