import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveExportText(String content, String fileName) async {
  final dir = await _getExportDirectory();
  await dir.create(recursive: true);

  final file = File('${dir.path}/$fileName');
  await file.writeAsString(content);

  return file.path;
}

Future<Directory> _getExportDirectory() async {
  if (Platform.isAndroid) {
    final dirs = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    if (dirs != null && dirs.isNotEmpty) {
      return dirs.first;
    }
  }

  final downloadsDir = await getDownloadsDirectory();
  if (downloadsDir != null) {
    return downloadsDir;
  }

  return await getApplicationDocumentsDirectory();
}
