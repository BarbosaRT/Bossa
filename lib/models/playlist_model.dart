import 'package:bossa/models/song_model.dart';

class PlaylistModel {
  int id = 0;
  String title = '';
  String icon = '';
  List<SongModel> songs = [];
  PlaylistModel(
      {required this.id,
      required this.title,
      required this.icon,
      required this.songs});

  factory PlaylistModel.fromMap(Map map) {
    return PlaylistModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      songs: [],
    );
  }

  Map<String, dynamic> toSql() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon,
    };
  }
}
