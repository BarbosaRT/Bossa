import 'dart:collection';

class Song {
  String title = '';
  String author = '';
  String icon = '';
  String audio = '';

  Map<String, String> toJson() {
    Map<String, String> output = HashMap();
    output.addAll({
      'title': title,
      'author': author,
      'icon': icon,
      'audio': audio,
    });
    return output;
  }
}
