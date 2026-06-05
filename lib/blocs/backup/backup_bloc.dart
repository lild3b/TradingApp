import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/backup_repository.dart';
import 'backup_file_size.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class BackupEvent extends Equatable {
  const BackupEvent();
  @override
  List<Object?> get props => [];
}

class ExportUserBackup extends BackupEvent {
  const ExportUserBackup(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class ExportAllUsersBackup extends BackupEvent {
  const ExportAllUsersBackup();
}

class ImportBackup extends BackupEvent {
  const ImportBackup(this.filePath);
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

class ImportBackupBytes extends BackupEvent {
  const ImportBackupBytes(this.bytes);
  final List<int> bytes;
  @override
  List<Object?> get props => [bytes];
}

class ExportImages extends BackupEvent {
  const ExportImages(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class BackupState extends Equatable {
  const BackupState();
  @override
  List<Object?> get props => [];
}

class BackupIdle extends BackupState {
  const BackupIdle();
}

class BackupInProgress extends BackupState {
  const BackupInProgress();
}

class BackupSuccess extends BackupState {
  const BackupSuccess({
    required this.filePath,
    required this.fileSize,
    required this.exportedAt,
    this.message = 'Backup completed successfully',
    this.importedProfileId,
  });
  final String filePath;
  final String fileSize;
  final DateTime exportedAt;
  final String message;
  final String? importedProfileId;
  @override
  List<Object?> get props =>
      [filePath, fileSize, exportedAt, message, importedProfileId];
}

class BackupError extends BackupState {
  const BackupError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  BackupBloc({
    required BackupRepository backupRepository,
  })  : _backupRepo = backupRepository,
        super(const BackupIdle()) {
    on<ExportUserBackup>(_onExportUser);
    on<ExportAllUsersBackup>(_onExportAll);
    on<ImportBackup>(_onImport);
    on<ImportBackupBytes>(_onImportBytes);
    on<ExportImages>(_onExportImages);
  }

  final BackupRepository _backupRepo;

  Future<void> _onExportUser(
      ExportUserBackup event, Emitter<BackupState> emit) async {
    emit(const BackupInProgress());
    try {
      final path = await _backupRepo.exportUserBackup(event.userId);
      final size = await _getFileSize(path);
      emit(BackupSuccess(
        filePath: path,
        fileSize: size,
        exportedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<void> _onExportAll(
      ExportAllUsersBackup event, Emitter<BackupState> emit) async {
    emit(const BackupInProgress());
    try {
      final path = await _backupRepo.exportAllUsersBackup();
      final size = await _getFileSize(path);
      emit(BackupSuccess(
        filePath: path,
        fileSize: size,
        exportedAt: DateTime.now(),
        message: 'All users backup completed',
      ));
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<void> _onImport(ImportBackup event, Emitter<BackupState> emit) async {
    await _import(
      emit,
      () => _backupRepo.importBackup(event.filePath),
    );
  }

  Future<void> _onImportBytes(
    ImportBackupBytes event,
    Emitter<BackupState> emit,
  ) async {
    await _import(
      emit,
      () => _backupRepo.importBackupBytes(event.bytes),
    );
  }

  Future<void> _import(
    Emitter<BackupState> emit,
    Future<BackupImportResult> Function() importAction,
  ) async {
    emit(const BackupInProgress());
    try {
      final result = await importAction();
      emit(BackupSuccess(
        filePath: '',
        fileSize: '',
        exportedAt: DateTime(0),
        message: 'Imported ${result.profileCount} profile(s), '
            '${result.tradeCount} trade(s), and ${result.tagCount} tag(s)',
        importedProfileId: result.firstProfileId,
      ));
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<void> _onExportImages(
      ExportImages event, Emitter<BackupState> emit) async {
    emit(const BackupInProgress());
    try {
      emit(BackupSuccess(
        filePath: '',
        fileSize: '0 KB',
        exportedAt: DateTime.now(),
        message: 'Images exported',
      ));
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  Future<String> _getFileSize(String path) async {
    if (path.isEmpty) return '0 KB';
    return getBackupFileSize(path);
  }
}
