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
    required this.path,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      url: map['url'] as String,
      path: map['path'] as String,
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

  SongModel copyWith({
    int? id,
    String? title,
    String? icon,
    String? url,
    String? path,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      path: path ?? this.path,
    );
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
