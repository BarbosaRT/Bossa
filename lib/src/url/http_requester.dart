import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class HttpRequester {
  http.Client client = http.Client();

  Future<dynamic> retriveFromUrl(String link) async {
    try {
      if (Platform.isLinux) {
        var result = await Dio().get(link);
        return result.data;
      }
      var response = await client.get(Uri.parse(link));
      var data = jsonDecode(response.body);
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
