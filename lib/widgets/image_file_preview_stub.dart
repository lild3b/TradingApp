import 'package:flutter/material.dart';

Widget buildImageFilePreview(String path) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(16),
    color: Colors.black12,
    child: const Text(
      'This image uses a local desktop file path.\nRe-add it on web or import a backup with embedded images.',
      textAlign: TextAlign.center,
    ),
  );
}
