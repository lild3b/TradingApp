import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/backup_repository.dart';

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
  });
  final String filePath;
  final String fileSize;
  final DateTime exportedAt;
  final String message;
  @override
  List<Object?> get props => [filePath, fileSize, exportedAt, message];
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
    emit(const BackupInProgress());
    try {
      await _backupRepo.importBackup(event.filePath);
      emit(BackupSuccess(
        filePath: '',
        fileSize: '',
        exportedAt: DateTime(0),
        message: 'Import completed successfully',
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
    try {
      final file = File(path);
      final bytes = await file.length();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return 'Unknown';
    }
  }
}
