import 'package:bossa/models/playlist_model.dart';
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

  void setPlaylist(PlaylistModel newPlaylist) {
    currentPlaylist = newPlaylist;
    setHasPlayedOnce(true);
    notifyListeners();
  }
}
