import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  FileService._();
  static final FileService _instance = FileService._();
  static FileService get instance => _instance;

  Future<String?> saveFile({
    required String filename,
    required List<int> bytes,
    required String mimeType,
    String? directory,
  }) async {
    if (kIsWeb) {
      return null;
    }
    final targetDir = directory != null && directory.isNotEmpty
        ? Directory(directory)
        : await getApplicationDocumentsDirectory();
    await targetDir.create(recursive: true);
    final file = File('${targetDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> shareFile({
    required String filePath,
    required String subject,
    String? mimeType,
  }) async {
    // share_plus v10 API
    await Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType)],
      subject: subject,
    );
  }

  Future<String> getTempDir() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<String> getDocumentsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
