import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/audio/just_playlist_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

PlaylistModel setUpPlaylist() {
  return PlaylistModel(
    id: 0,
    title: 'Test playlist',
    icon: '',
    songs: [
      SongModel(
        id: 0,
        title: 'Song 1',
        path: '',
        url:
            'http://commondatastorage.googleapis.com/codeskulptor-assets/week7-brrring.m4a',
        icon: '',
      ),
      SongModel(
        id: 1,
        title: 'Song 2',
        path: '',
        url:
            'http://commondatastorage.googleapis.com/codeskulptor-assets/week7-button.m4a',
        icon: '',
      ),
    ],
  );
}

void main() {
  group('JustPlaylistManager', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    JustPlaylistManager manager = JustPlaylistManager();

    test('setPlaylist', () async {
      // Create a playlist with two songs
      PlaylistModel playlist = setUpPlaylist();

      await manager.setPlaylist(playlist);

      // Verify that the playlist was set correctly
      expect(manager.playlistAudioSource.children.length, 2);
      expect(manager.playlistAudioSource.children[0],
          AudioSource.uri(Uri.parse(playlist.songs[0].url)));

      expect(manager.playlistAudioSource.children[1],
          AudioSource.uri(Uri.parse(playlist.songs[1].url)));
    });

    test('seekToNext', () async {
      // Create a playlist with three songs
      PlaylistModel playlist = setUpPlaylist();
      playlist.songs.add(SongModel(
        id: 2,
        title: 'Song 3',
        icon: '',
        path: '',
        url:
            'http://commondatastorage.googleapis.com/codeskulptor-assets/week7-bounce.m4a',
      ));

      await manager.setPlaylist(playlist, initialIndex: 0);
      await manager.seekToNext();

      // Verify that the current song is the second song in the playlist
      expect(manager.player.currentIndex, 1);
      expect(manager.playlistAudioSource.children[manager.player.currentIndex!],
          AudioSource.uri(Uri.parse(playlist.songs[1].url)));

      await manager.seekToNext();

      // Verify that the current song is the third song in the playlist
      expect(manager.player.currentIndex, 2);
      expect(manager.playlistAudioSource.children[manager.player.currentIndex!],
          AudioSource.uri(Uri.parse(playlist.songs[2].url)));

      await manager.seekToNext();

      // Verify that the current song is the first song in the playlist (loop mode is enabled by default)
      expect(manager.player.currentIndex, 0);
      expect(manager.playlistAudioSource.children[manager.player.currentIndex!],
          AudioSource.uri(Uri.parse(playlist.songs[0].url)));
    });

    test('seekToPrevious', () async {
      // Create a playlist with three songs
      PlaylistModel playlist = setUpPlaylist();

      await manager.setPlaylist(playlist, initialIndex: 1);
      await manager.seekToPrevious();

      // Verify that the current song is the first song in the playlist
      expect(manager.player.currentIndex, 0);
      expect(manager.playlistAudioSource.children[manager.player.currentIndex!],
          AudioSource.uri(Uri.parse(playlist.songs[0].url)));
    });

    test('seek', () async {
      // Create a playlist with three songs
      PlaylistModel playlist = setUpPlaylist();

      await manager.setPlaylist(playlist);
      await manager.seek(const Duration(seconds: 90), 0);

      // Verify that the current position is 90 seconds into the first song
      expect(manager.player.position, const Duration(seconds: 90));
    });
  });
}
