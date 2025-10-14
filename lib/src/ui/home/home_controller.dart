import 'package:bossa/models/playlist_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class HomeController extends ChangeNotifier {
  Pages _currentPage = Pages.home;
  Pages get currentPage => _currentPage;

  void setCurrentPage(Pages newPage) {
    _currentPage = newPage;
    notifyListeners();
  }

  PlaylistModel _currentPlaylist =
      PlaylistModel(id: 0, title: 'all-songs'.i18n(), icon: 'icon', songs: []);
  PlaylistModel get currentPlaylist => _currentPlaylist;

  void setPlaylist(PlaylistModel newPlaylist) {
    _currentPlaylist = newPlaylist;
    notifyListeners();
  }

  bool _searchLibrary = false;
  bool get searchLibrary => _searchLibrary;

  void setSearchLibrary(bool value) {
    _searchLibrary = value;
    notifyListeners();
  }

  String _lastSearchedTopic = '';
  String get lastSearchedTopic => _lastSearchedTopic;

  void setlastSearchedTopic(String value) {
    _lastSearchedTopic = value;
    notifyListeners();
  }
}

enum Pages { home, search, library, settings, playlist }
