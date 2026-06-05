import 'dart:convert';
import 'dart:io';

Future<String?> readImageDataUrl(String? path) async {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('data:')) return path;

  final file = File(path);
  if (!await file.exists()) return null;

  final bytes = await file.readAsBytes();
  final mimeType = _mimeTypeForPath(path);
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

String _mimeTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}
