import 'backup_image_data_stub.dart'
    if (dart.library.io) 'backup_image_data_io.dart';

Future<String?> imagePathToDataUrl(String? path) => readImageDataUrl(path);
