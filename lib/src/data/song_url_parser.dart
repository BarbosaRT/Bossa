import 'dart:convert';
import 'package:http/http.dart' as http;

class SongUrlParser {
  String apiUrl =
      'https://api.invidious.io/instances.json?pretty=1&sort_by=type,users';

  List<String> youtubeUrls = [
    'https://www.youtube.com/watch?v=',
    'https://youtu.be/'
  ];

  http.Client client = http.Client();

  Future<dynamic> getHttp(String link) async {
    try {
      var response = jsonDecode((await client.get(Uri.parse(link))).body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  bool isSongFromYoutube(String input) {
    bool output = false;
    for (String url in youtubeUrls) {
      bool aux = input.contains(url);
      output = aux ? aux : output;
    }
    return output;
  }

  String parseSongUrlToSave(String input) {
    String output = input.toString();

    if (isSongFromYoutube(input)) {
      for (String url in youtubeUrls) {
        output = output.replaceAll(url, '');
      }
    }
    return output.substring(0, 11);
  }

  Future<String> parseSongUrlToInvidious(String url) async {
    List<dynamic> invidiousInstances = await getHttp(apiUrl) as List<dynamic>;
    String info = (invidiousInstances[0][1]['uri']).toString();
    return '$info/watch?v=$url';
  }
}
