import 'dart:io';

Future<String> readFile(String path) async {
  final file = File(path);
  return file.readAsString();
}
