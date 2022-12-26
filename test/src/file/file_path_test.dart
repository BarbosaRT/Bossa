import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/src/file/file_path.dart';

void main() {
  group('FilePath', () {
    test('getWorkingDirectory', () {
      final filePath = FilePathImpl();

      expect(filePath.getWorkingDirectory,
          '${filePath.getDocumentsDirectory()}/bossa');
    });

    test('getDocumentsDirectory', () async {
      final filePath = FilePathImpl();

      final output = await filePath.getDocumentsDirectory();
      expect(output, isNotNull);
    });
  });
}
