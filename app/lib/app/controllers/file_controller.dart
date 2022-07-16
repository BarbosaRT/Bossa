import 'dart:convert';
import 'dart:io';

import 'package:bossa/app/models/song_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileController {
  Song songFile = Song();
  late File jsonFile;
  bool fileExists = false;
  late Map<String, String> fileContent;
  Directory dir = Directory('');

  void createFile(
      Map<String, dynamic> content, Directory dir, String fileName) {
    // Creates the file! ${dir.path}/$fileName"
    File file = File("${dir.path}/$fileName");
    file.createSync();
    fileExists = true;
    final encoded = '[${jsonEncode(content)}]';
    file.writeAsStringSync(encoded);
    //file.writeAsStringSync(JSON.encode(content));
  }

  void writeToFile(Map<String, String> content) {
    //Writing to file!
    if (fileExists) {
      List<dynamic> jsonFileContent = jsonDecode(jsonFile.readAsStringSync());

      jsonFileContent.add(jsonEncode(content));

      String output =
          jsonEncode(jsonFileContent).replaceAll('[', '').replaceAll(']', '');

      jsonFile.writeAsStringSync('[$output]');
    } else if (dir.path != '') {
      // File does not exist!
      createFile(content, dir, 'songs.json');
    }
  }

  void saveData(
      String musicPath, String author, String title, String iconPath) {
    songFile.audio = musicPath;
    songFile.author = author;
    songFile.title = title;
    songFile.icon = iconPath;
    if (dir.path != '') {
      writeToFile(songFile.toJson());
    }
  }

  Future<File?>? selectFile(FileType fileType) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: fileType);
    if (result == null) {
      return null;
    }
    final file = result.files.first;
    final newFile = await saveFilePermanently(file);
    return newFile;
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }
}
