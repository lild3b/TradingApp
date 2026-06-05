import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> copyToAppDir(String sourcePath) async {
  final source = File(sourcePath);
  if (!await source.exists()) return sourcePath;

  final appDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(appDir.path, 'trade_images'));
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final extension = p.extension(sourcePath);
  final filename = 'trade_${DateTime.now().microsecondsSinceEpoch}$extension';
  final destinationPath = p.join(imagesDir.path, filename);
  final copied = await source.copy(destinationPath);
  return copied.path;
}

Future<void> deleteImageFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<List<String>> getTradeImagePaths() async {
  final appDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(appDir.path, 'trade_images'));
  if (!await imagesDir.exists()) return const [];

  final paths = <String>[];
  await for (final entity in imagesDir.list()) {
    if (entity is File) paths.add(entity.path);
  }
  return paths;
}
