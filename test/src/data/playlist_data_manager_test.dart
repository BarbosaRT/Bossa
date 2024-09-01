import 'dart:io';
import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/playlist_data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:bossa/src/url/download_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/models/song_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('PlaylistDataManager', () {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final playlistDataManager =
        PlaylistDataManager(localDataManagerInstance: testDataManagerInstance);
    final songDataManager = SongDataManager(
        localDataManagerInstance: testDataManagerInstance,
        downloadService: HttpDownloadService(filePath: FilePathImpl()));
    final playlist1 =
        PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);

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
      PlaylistModel playlist2 =
          PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);

      SongModel song2 = SongModel(
          id: 1,
          title: 'Song 1',
          icon: 'icon1',
          url: 'https://youtu.be/NgYoUsdETRw',
          path: 'path1');

      playlistDataManager.deleteAll();
      songDataManager.deleteAll();

      playlistDataManager.addPlaylist(playlist2);
      songDataManager.addSong(song2);

      // Correct the ids
      playlist2 = await playlistDataManager.loadLastAddedPlaylist();
      song2 = await songDataManager.loadLastAddedSong();

      playlistDataManager.appendToPlaylist(song2, playlist2);

      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists[0].songs[0].id, song2.id);
    });

    test('test if loadPlaylists returns a empty list when list is empty',
        () async {
      playlistDataManager.deleteAll();
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();
      expect(loadedPlaylists, []);
    });

    test('test if removes song from playlist', () async {
      PlaylistModel playlist2 =
          PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);

      SongModel song2 = SongModel(
          id: 1,
          title: 'Song 1',
          icon: 'icon1',
          url: 'https://youtu.be/NgYoUsdETRw',
          path: 'path1');

      playlistDataManager.deleteAll();
      songDataManager.deleteAll();

      playlistDataManager.addPlaylist(playlist2);
      songDataManager.addSong(song2);

      // Correct the ids
      playlist2 = await playlistDataManager.loadLastAddedPlaylist();
      song2 = await songDataManager.loadLastAddedSong();

      playlistDataManager.appendToPlaylist(song2, playlist2);
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();

      playlistDataManager.deleteFromPlaylist(song2, playlist2);
      List<PlaylistModel> loadedPlaylists2 =
          await playlistDataManager.loadPlaylists();

      expect(loadedPlaylists[0].songs.isNotEmpty, true);
      expect(loadedPlaylists2[0].songs.isEmpty, true);
    });

    test('test if deletePlaylist delete a playlist', () async {
      PlaylistModel playlist2 =
          PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);

      playlistDataManager.deleteAll();

      playlistDataManager.addPlaylist(playlist2);
      List<PlaylistModel> loadedPlaylists =
          await playlistDataManager.loadPlaylists();

      // Correct the ids
      playlist2 = loadedPlaylists[0];

      playlistDataManager.deletePlaylist(playlist2);
      List<PlaylistModel> loadedPlaylists2 =
          await playlistDataManager.loadPlaylists();

      expect(loadedPlaylists2.isEmpty, true);
      expect(loadedPlaylists2.length, loadedPlaylists.length - 1);
    });

    test('test if editPlaylist edit a playlist', () async {
      final playlist2 =
          PlaylistModel(id: 1, title: 'Song 1', icon: 'icon1', songs: []);
      playlistDataManager.deleteAll();
      playlistDataManager.addPlaylist(playlist2);

      playlist2.title = 'EditedTitle';

      playlistDataManager.editPlaylist(playlist2);
      List<PlaylistModel> loadedPlaylists2 =
          await playlistDataManager.loadPlaylists();

      expect(loadedPlaylists2[0].title == 'EditedTitle', true);
    });
  });
}
