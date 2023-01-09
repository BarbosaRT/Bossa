class SongModel {
  int id = 0;
  String title = '';
  String icon = '';
  String url = '';
  String path = '';

  SongModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
    this.path = '',
  });

  factory SongModel.fromMap(Map map) {
    return SongModel(
        id: map['id'] as int,
        title: map['title'] as String,
        icon: map['icon'] as String,
        url: map['url'] as String,
        path: map['path'] as String);
  }

  @override
  bool operator ==(covariant SongModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.icon == icon &&
        other.url == url &&
        other.path == path;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        icon.hashCode ^
        url.hashCode ^
        path.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon,
      'url': url,
      'path': path,
    };
  }
}
