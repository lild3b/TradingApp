Future<String> copyToAppDir(String sourcePath) {
  throw UnsupportedError('Local image file storage is not available on web.');
}

Future<void> deleteImageFile(String path) async {}

Future<List<String>> getTradeImagePaths() async => const [];
