class SongModel {
  int id = 0;
  String title = '';
  String icon = '';
  String url = '';
  String path = '';
  String author = '';
  int timesPlayed = 0;

  SongModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
    this.path = '',
    this.author = '',
    this.timesPlayed = 0,
  });

  factory SongModel.fromMap(Map map) {
    String author = '';
    if (map['author'] != null) {
      author = map['author'] as String;
    }
    int timesPlayed = 0;
    if (map['timesPlayed'] != null) {
      timesPlayed = map['timesPlayed'] as int;
    }

    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      url: map['url'] as String,
      path: map['path'] as String,
      author: author,
      timesPlayed: timesPlayed,
    );
  }

  @override
  bool operator ==(covariant SongModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.icon == icon &&
        other.url == url &&
        other.path == path &&
        other.author == author;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        icon.hashCode ^
        url.hashCode ^
        path.hashCode ^
        author.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon,
      'url': url,
      'path': path,
      'author': author,
      'timesPlayed': timesPlayed,
    };
  }
}
