import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:bossa/src/data/data_manager.dart';
import 'package:bossa/src/data/song_data_manager.dart';

class PlaylistDataManager {
  PlaylistDataManager() {
    init();
  }

  void init() async {
    dataManagerInstance.databaseHandler('''CREATE TABLE IF NOT EXISTS playlists(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      title text,
      icon text
    );''');
    SongDataManager().init();
    dataManagerInstance
        .databaseHandler('''CREATE TABLE IF NOT EXISTS playlists_songs(
      id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
      idPlaylist integer NOT NULL,
      idSong integer NOT NULL, 
      FOREIGN KEY(idPlaylist) REFERENCES playlists(id),
      FOREIGN KEY(idSong) REFERENCES songs(id) 
    );''');
  }

  void addToPlaylist(SongModel song, PlaylistModel playlist) {
    dataManagerInstance.databaseHandler('command');
  }

  void loadPlaylists(){}

}
