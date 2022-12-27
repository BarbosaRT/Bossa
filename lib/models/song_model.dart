class SongModel {
  int id = 0;
  String title = '';
  String icon = '';
  String? url = '';
  String? path = '';
  SongModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
    required this.path,
  });

  String toSQL() {
    return "('$title', '$icon', '$url', '$path')";
  }

  factory SongModel.fromMap(Map<dynamic, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      path: map['path'] != null ? map['path'] as String : null,
    );
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
}
