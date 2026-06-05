Future<String?> readImageDataUrl(String? path) async {
  if (path == null || path.isEmpty) return null;
  return path.startsWith('data:') ? path : null;
}
