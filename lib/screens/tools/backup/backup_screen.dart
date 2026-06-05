import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../blocs/backup/backup_bloc.dart';
import '../../../blocs/user_profile/user_profile_bloc.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../blocs/calendar/calendar_bloc.dart';
import '../../../blocs/journal/journal_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../services/file_service.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: (context, state) {
          if (state is BackupSuccess) {
            if (state.importedProfileId != null) {
              final importedProfileId = state.importedProfileId!;
              context.read<UserProfileBloc>().add(
                    LoadProfiles(selectProfileId: importedProfileId),
                  );
              context.read<AnalyticsBloc>().add(
                    LoadAnalytics(importedProfileId),
                  );
              final now = DateTime.now();
              context.read<CalendarBloc>().add(
                    LoadCalendarMonth(
                      userId: importedProfileId,
                      year: now.year,
                      month: now.month,
                    ),
                  );
              context.read<JournalBloc>().add(
                    LoadJournal(importedProfileId),
                  );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.profit,
              ),
            );
            if (state.filePath.isNotEmpty) {
              FileService.instance.shareFile(
                filePath: state.filePath,
                subject: 'Trading Journal Backup',
                mimeType: 'application/json',
              );
            }
          } else if (state is BackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.loss,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BackupInProgress;
          final profileState = context.read<UserProfileBloc>().state;
          final userId = profileState is ProfileSelected
              ? profileState.selectedProfile.id
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                  ],

                  // Last backup info
                  if (state is BackupSuccess) ...[
                    _InfoCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.profit,
                      title: 'Last Backup',
                      subtitle:
                          '${AppFormatters.dateTime(state.exportedAt)} · ${state.fileSize}',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Export section
                  _SectionHeader('Export'),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Export My Data',
                    subtitle: 'Backup current profile trades as JSON',
                    onTap: userId == null || isLoading
                        ? null
                        : () => context
                            .read<BackupBloc>()
                            .add(ExportUserBackup(userId)),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.group_outlined,
                    title: 'Export All Profiles',
                    subtitle: 'Backup every profile and their trades',
                    onTap: isLoading
                        ? null
                        : () => context
                            .read<BackupBloc>()
                            .add(const ExportAllUsersBackup()),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.photo_library_outlined,
                    title: 'Export Trade Images',
                    subtitle: 'Download all entry/result screenshots',
                    onTap: userId == null || isLoading
                        ? null
                        : () => context
                            .read<BackupBloc>()
                            .add(ExportImages(userId)),
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader('Import'),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.upload_file_outlined,
                    title: 'Import / Restore',
                    subtitle: 'Restore from a JSON backup file',
                    color: AppColors.warningYellow,
                    onTap: isLoading ? null : () => _pickAndImport(context),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningYellow.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.warningYellow.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.warningYellow, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Importing will add data alongside existing profiles. '
                            'It will not delete your current data.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.warningYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAndImport(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null) return;
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Backup'),
        content: const Text(
          'This will import all profiles and trades from the selected file. '
          'Existing data will not be deleted.\n\nContinue?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Import')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final pickedFile = result.files.single;
      final bytes = pickedFile.bytes;

      if (bytes != null) {
        context.read<BackupBloc>().add(ImportBackupBytes(bytes));
        return;
      }

      String? path;
      try {
        path = pickedFile.path;
      } catch (_) {
        path = null;
      }

      if (path != null) {
        context.read<BackupBloc>().add(ImportBackup(path));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected backup file could not be read.'),
          backgroundColor: AppColors.loss,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: activeColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(subtitle,
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
