import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    return '(DEFAULT, $title, $icon, $url, $path)';
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

  factory SongModel.fromMap(Map<dynamic, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      icon: map['icon'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      path: map['path'] != null ? map['path'] as String : null,
    );
  }
}
