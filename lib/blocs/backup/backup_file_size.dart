import 'backup_file_size_stub.dart'
    if (dart.library.io) 'backup_file_size_io.dart';

Future<String> getBackupFileSize(String path) => getFileSize(path);
