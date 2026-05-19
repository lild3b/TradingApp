import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  ImageService._();
  static final ImageService _instance = ImageService._();
  static ImageService get instance => _instance;

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (xFile == null) return null;
    return _copyToAppDir(xFile.path);
  }

  Future<String> _copyToAppDir(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'trade_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}';
    final destPath = p.join(imagesDir.path, filename);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<String>> getAllTradeImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'trade_images'));
    if (!await imagesDir.exists()) return [];
    return imagesDir
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .toList();
  }
}
