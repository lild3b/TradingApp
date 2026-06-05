import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'image_file_storage.dart';

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
    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      final mimeType = xFile.mimeType ?? _mimeTypeForName(xFile.name);
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    }
    return copyImageToAppDir(xFile.path);
  }

  Future<void> deleteImage(String path) async {
    if (!path.startsWith('data:')) {
      await deleteStoredImage(path);
    }
  }

  Future<List<String>> getAllTradeImages() async {
    return getStoredTradeImages();
  }

  String _mimeTypeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
