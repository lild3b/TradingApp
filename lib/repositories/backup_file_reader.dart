import 'backup_file_reader_stub.dart'
    if (dart.library.io) 'backup_file_reader_io.dart';

Future<String> readBackupFile(String path) => readFile(path);
