import 'dart:collection';

class SongModel {
  String title = '';
  String author = '';
  String icon = '';
  String audio = '';

  List<String> toList(){
    return [
      title, author, icon, audio
    ];
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'author': author,
      'icon': icon,
      'audio': audio,
    };
  }

  Map<String, String> toJson() {
    Map<String, String> output = HashMap();
    output.addAll(toMap());
    return output;
  }

  bool isFilled(){
    final bool isFilled = (title != '' && author != ''&& icon != '' && audio != '');
    return isFilled;
  }
}
