import 'package:flutter/material.dart';

import 'image_file_preview_stub.dart'
    if (dart.library.io) 'image_file_preview_io.dart';

class ImageFilePreview extends StatelessWidget {
  const ImageFilePreview({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => buildImageFilePreview(path);
}
