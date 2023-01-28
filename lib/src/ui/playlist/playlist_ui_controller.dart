import 'package:bossa/models/playlist_model.dart';
import 'package:bossa/models/song_model.dart';
import 'package:flutter/widgets.dart';

class PlaylistUIController extends ChangeNotifier {
  PlaylistModel currentPlaylist =
      PlaylistModel(id: 0, title: '', icon: '', songs: []);

  PlaylistModel get playlist => currentPlaylist;

  bool _hasPlayedOnce = false;
  bool get hasPlayedOnce => _hasPlayedOnce;

  void setHasPlayedOnce(bool value) {
    _hasPlayedOnce = value;
    notifyListeners();
  }

  void setPlaylist(PlaylistModel newPlaylist, {int index = 0}) {
    currentPlaylist = PlaylistModel.fromMap(newPlaylist.toMap());

    List<SongModel> songs = playlist.songs.toList();
    List<SongModel> begin = songs.sublist(0, index).toList();
    List<SongModel> end = songs.sublist(index, songs.length).toList();
    songs = end + begin;
    currentPlaylist.songs = songs.toList();

    setHasPlayedOnce(true);
    notifyListeners();
  }
}
