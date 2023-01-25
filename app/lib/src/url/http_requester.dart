import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpRequester {
  http.Client client = http.Client();

  Future<dynamic> retriveFromUrl(String link) async {
    try {
      var response = jsonDecode((await client.get(Uri.parse(link))).body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
