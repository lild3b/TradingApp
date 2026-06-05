import 'dart:io';

import 'package:flutter/material.dart';

Widget buildImageFilePreview(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return _MissingLocalImage(path: path);
  }

  return Image.file(
    file,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _MissingLocalImage(path: path),
  );
}

class _MissingLocalImage extends StatelessWidget {
  const _MissingLocalImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Text(
        'Image file not found.\nRe-add this screenshot.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
