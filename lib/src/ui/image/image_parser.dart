import 'dart:io';

import 'package:bossa/src/url/url_parser.dart';
import 'package:flutter/material.dart';

class ImageParser {
  static ImageProvider getImageProviderFromString(String image) {
    if (UrlParser.validUrl(image)) {
      return NetworkImage(image);
    }
    if (image.contains('assets/images')) {
      return AssetImage(image);
    }
    return FileImage(File(image));
  }
}
