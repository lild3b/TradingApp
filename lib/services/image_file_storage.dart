import 'image_file_storage_stub.dart'
    if (dart.library.io) 'image_file_storage_io.dart';

Future<String> copyImageToAppDir(String sourcePath) {
  return copyToAppDir(sourcePath);
}

Future<void> deleteStoredImage(String path) {
  return deleteImageFile(path);
}

Future<List<String>> getStoredTradeImages() {
  return getTradeImagePaths();
}
