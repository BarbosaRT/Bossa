import 'package:flutter_test/flutter_test.dart';
import 'package:bossa/src/file/file_path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('FilePath', () {
    test('getDocumentsDirectory', () async {
      final filePath = FilePathImpl();

      final output = await filePath.getDocumentsDirectory();
      expect(output, isNotNull);
      expect(output != '/bossa', true);
    });

    test('getDocumentsDirectory from path_provider', () async {
      final output = await getApplicationDocumentsDirectory();
      expect(output, isNotNull);
    });
  });
}
