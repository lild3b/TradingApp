import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/user_profile/user_profile_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/notification/notification_bloc.dart';
import '../../../blocs/theme/theme_bloc.dart';
import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../models/user_profile.dart';
import '../../../services/secure_storage_service.dart';
import '../../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, profileState) {
          if (profileState is! ProfileSelected) {
            return const Center(child: Text('No profile selected'));
          }
          final profile = profileState.selectedProfile;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─ Account ───────────────────────────────────────────────────
              _SectionHeader('Account'),
              const SizedBox(height: 8),
              _AccountSection(profile: profile),
              const SizedBox(height: 24),

              // ─ Security ──────────────────────────────────────────────────
              _SectionHeader('Security'),
              const SizedBox(height: 8),
              _SecuritySection(profile: profile),
              const SizedBox(height: 24),

              // ─ Preferences ───────────────────────────────────────────────
              _SectionHeader('Preferences'),
              const SizedBox(height: 8),
              _PreferencesSection(profile: profile),
              const SizedBox(height: 24),

              // ─ App ───────────────────────────────────────────────────────
              _SectionHeader('App'),
              const SizedBox(height: 8),
              _AppSection(),
              const SizedBox(height: 24),

              // ─ Notifications ─────────────────────────────────────────────
              _SectionHeader('Notifications'),
              const SizedBox(height: 8),
              _NotificationsSection(),
              const SizedBox(height: 40),

              // Danger zone
              _SectionHeader('Danger Zone', color: AppColors.loss),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.loss,
                  side: const BorderSide(color: AppColors.loss),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Switch Profile'),
                onPressed: () {
                  context
                      .read<UserProfileBloc>()
                      .add(const SelectProfile(null));
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.loss,
                  side: const BorderSide(color: AppColors.loss),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete Profile'),
                onPressed: () => _showDeleteProfileDialog(context, profile),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteProfileDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('This will delete all data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserProfileBloc>().add(DeleteProfile(profile.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Account Section ──────────────────────────────────────────────────────────

class _AccountSection extends StatefulWidget {
  const _AccountSection({required this.profile});
  final UserProfile profile;

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  late double _dailyLoss;
  late double _maxLoss;

  @override
  void initState() {
    super.initState();
    _dailyLoss = widget.profile.dailyPermittedLossPercent;
    _maxLoss = widget.profile.maxPermittedLossPercent;
  }

  void _updateProfile(UserProfile updated) {
    context.read<UserProfileBloc>().add(UpdateProfile(updated));
    context.read<AnalyticsBloc>().add(LoadAnalytics(updated.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return _SettingsCard(
      children: [
        // Account type toggle
        _SettingRow(
          icon: Icons.business_outlined,
          title: 'Account Type',
          trailing: DropdownButton<AccountType>(
            value: p.accountType,
            underline: const SizedBox.shrink(),
            onChanged: (v) {
              if (v != null) _updateProfile(p.copyWith(accountType: v));
            },
            items: const [
              DropdownMenuItem(
                  value: AccountType.personal, child: Text('Personal')),
              DropdownMenuItem(
                  value: AccountType.propFirm, child: Text('Prop Firm')),
            ],
          ),
        ),
        const Divider(height: 1),

        // Balance
        _SettingRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Balance',
          subtitle: '\$${p.balance.toStringAsFixed(2)}',
          onTap: () => _showBalanceDialog(context, p),
        ),
        const Divider(height: 1),

        // Daily loss %
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_outlined,
                      size: 18, color: AppColors.warningYellow),
                  const SizedBox(width: 10),
                  Text('Daily Loss Limit: ${_dailyLoss.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Slider(
                value: _dailyLoss,
                min: 1.0,
                max: 20.0,
                divisions: 38,
                onChanged: (v) => setState(() => _dailyLoss = v),
                onChangeEnd: (v) =>
                    _updateProfile(p.copyWith(dailyPermittedLossPercent: v)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Max loss %
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.block_outlined,
                      size: 18, color: AppColors.warningOrange),
                  const SizedBox(width: 10),
                  Text('Max Drawdown: ${_maxLoss.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Slider(
                value: _maxLoss,
                min: 1.0,
                max: 30.0,
                divisions: 58,
                onChanged: (v) => setState(() => _maxLoss = v),
                onChangeEnd: (v) =>
                    _updateProfile(p.copyWith(maxPermittedLossPercent: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBalanceDialog(BuildContext context, UserProfile p) {
    final ctrl = TextEditingController(text: p.balance.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Balance'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null) _updateProfile(p.copyWith(balance: val));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Security Section ─────────────────────────────────────────────────────────

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        // PIN toggle
        _SettingRow(
          icon: Icons.lock_outline_rounded,
          title: 'PIN Lock',
          subtitle: profile.pinEnabled ? 'Enabled' : 'Disabled',
          trailing: Switch(
            value: profile.pinEnabled,
            onChanged: (enabled) {
              if (enabled) {
                context.push('/tools/settings/pin-setup');
              } else {
                context.read<AuthBloc>().add(DisablePin(profile.id));
                context
                    .read<UserProfileBloc>()
                    .add(UpdateProfile(profile.copyWith(pinEnabled: false)));
              }
            },
          ),
        ),
        const Divider(height: 1),

        // Biometric toggle
        _SettingRow(
          icon: Icons.fingerprint_rounded,
          title: 'Biometric Unlock',
          subtitle: profile.biometricEnabled ? 'Enabled' : 'Disabled',
          trailing: Switch(
            value: profile.biometricEnabled,
            onChanged: profile.pinEnabled
                ? (enabled) {
                    context.read<UserProfileBloc>().add(UpdateProfile(
                        profile.copyWith(biometricEnabled: enabled)));
                  }
                : null,
          ),
        ),
        const Divider(height: 1),

        // Lock after
        _SettingRow(
          icon: Icons.timer_outlined,
          title: 'Lock After',
          trailing: DropdownButton<int>(
            value: profile.lockAfterSeconds,
            underline: const SizedBox.shrink(),
            onChanged: (v) {
              if (v != null) {
                context
                    .read<UserProfileBloc>()
                    .add(UpdateProfile(profile.copyWith(lockAfterSeconds: v)));
              }
            },
            items: const [
              DropdownMenuItem(value: 0, child: Text('Immediately')),
              DropdownMenuItem(value: 60, child: Text('1 min')),
              DropdownMenuItem(value: 300, child: Text('5 min')),
              DropdownMenuItem(value: 900, child: Text('15 min')),
            ],
          ),
        ),

        if (profile.pinEnabled) ...[
          const Divider(height: 1),
          _SettingRow(
            icon: Icons.edit_rounded,
            title: 'Change PIN',
            onTap: () => context.push('/tools/settings/pin-setup'),
          ),
        ],
      ],
    );
  }
}

// ─── Preferences Section ──────────────────────────────────────────────────────

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        // Calendar start day
        _SettingRow(
          icon: Icons.calendar_today_outlined,
          title: 'Calendar Starts On',
          trailing: DropdownButton<CalendarStartDay>(
            value: profile.calendarStartDay,
            underline: const SizedBox.shrink(),
            onChanged: (v) {
              if (v != null) {
                context
                    .read<UserProfileBloc>()
                    .add(UpdateProfile(profile.copyWith(calendarStartDay: v)));
              }
            },
            items: const [
              DropdownMenuItem(
                  value: CalendarStartDay.sunday, child: Text('Sunday')),
              DropdownMenuItem(
                  value: CalendarStartDay.monday, child: Text('Monday')),
            ],
          ),
        ),
        const Divider(height: 1),

        // Default markets
        _SettingRow(
          icon: Icons.show_chart_rounded,
          title: 'Default Markets',
          subtitle: profile.defaultMarkets.isEmpty
              ? 'None configured'
              : profile.defaultMarkets.join(', '),
          onTap: () => _showMarketsDialog(context, profile),
        ),
      ],
    );
  }

  void _showMarketsDialog(BuildContext context, UserProfile p) {
    final ctrl = TextEditingController(text: p.defaultMarkets.join(', '));
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Default Markets'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'EURUSD, GBPUSD, SPY...',
            helperText: 'Comma-separated list',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final markets = ctrl.text
                  .split(',')
                  .map((m) => m.trim())
                  .where((m) => m.isNotEmpty)
                  .toList();
              context
                  .read<UserProfileBloc>()
                  .add(UpdateProfile(p.copyWith(defaultMarkets: markets)));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── App Section ──────────────────────────────────────────────────────────────

class _AppSection extends StatefulWidget {
  @override
  State<_AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<_AppSection> {
  String? _exportPath;
  String? _groqModelName;
  bool _hasGroqApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadExportPath();
    _loadGroqConfig();
  }

  Future<void> _loadExportPath() async {
    final path = await SecureStorageService.instance.read(
      SecureStorageService.exportPathKey,
    );
    if (!mounted) return;
    setState(() {
      _exportPath = path;
    });
  }

  Future<void> _saveExportPath(String path) async {
    if (path.isEmpty) {
      await SecureStorageService.instance
          .delete(SecureStorageService.exportPathKey);
    } else {
      await SecureStorageService.instance.write(
        SecureStorageService.exportPathKey,
        path,
      );
    }
    if (!mounted) return;
    setState(() {
      _exportPath = path.isEmpty ? null : path;
    });
  }

  Future<void> _editExportPath() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select export folder',
    );
    if (selectedPath == null) return;
    await _saveExportPath(selectedPath);
  }

  Future<void> _loadGroqConfig() async {
    final apiKey = await SecureStorageService.instance.read(
      SecureStorageService.groqApiKeyKey,
    );
    final modelName = await SecureStorageService.instance.read(
      SecureStorageService.groqModelNameKey,
    );

    if (!mounted) return;
    setState(() {
      _hasGroqApiKey = apiKey != null && apiKey.trim().isNotEmpty;
      _groqModelName = modelName?.trim().isEmpty ?? true
          ? null
          : modelName!.trim();
    });
  }

  Future<void> _saveGroqConfig({
    required String apiKey,
    required String modelName,
  }) async {
    await SecureStorageService.instance.write(
      SecureStorageService.groqApiKeyKey,
      apiKey,
    );
    await SecureStorageService.instance.write(
      SecureStorageService.groqModelNameKey,
      modelName,
    );

    if (!mounted) return;
    setState(() {
      _hasGroqApiKey = true;
      _groqModelName = modelName;
    });
  }

  Future<void> _editGroqConfig() async {
    final savedApiKey = await SecureStorageService.instance.read(
      SecureStorageService.groqApiKeyKey,
    );
    final savedModelName = await SecureStorageService.instance.read(
      SecureStorageService.groqModelNameKey,
    );

    if (!mounted) return;

    final apiKeyController = TextEditingController(text: savedApiKey ?? '');
    final modelController = TextEditingController(text: savedModelName ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Groq API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: 'Enter the model name',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Groq API Key',
                hintText: 'Enter your Groq API key',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = apiKeyController.text.trim();
              final modelName = modelController.text.trim();
              if (apiKey.isEmpty || modelName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Both API key and model are required'),
                  ),
                );
                return;
              }

              await _saveGroqConfig(
                apiKey: apiKey,
                modelName: modelName,
              );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    apiKeyController.dispose();
    modelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return _SettingsCard(
          children: [
            _SettingRow(
              icon: Icons.palette_outlined,
              title: 'Theme',
              trailing: DropdownButton<ThemeMode>(
                value: themeState.themeMode,
                underline: const SizedBox.shrink(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<ThemeBloc>().add(SetTheme(v));
                  }
                },
                items: const [
                  DropdownMenuItem(
                      value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(
                      value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
              ),
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.folder_open,
              title: 'Export Folder',
              subtitle: _exportPath == null || _exportPath!.isEmpty
                  ? 'Default application folder'
                  : _exportPath,
              onTap: _editExportPath,
            ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.smart_toy_outlined,
              title: 'Groq API',
              subtitle: _hasGroqApiKey && _groqModelName != null
                  ? 'Saved: $_groqModelName'
                  : 'Not configured',
              onTap: _editGroqConfig,
            ),
          ],
        );
      },
    );
  }
}

// ─── Notifications Section ────────────────────────────────────────────────────

class _NotificationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is! NotificationLoaded) {
          return const SizedBox(
              height: 60, child: Center(child: CircularProgressIndicator()));
        }
        final settings = state.settings;
        return _SettingsCard(
          children: [
            // Daily reminder toggle
            _SettingRow(
              icon: Icons.notifications_outlined,
              title: 'Daily Reminder',
              subtitle: settings.dailyReminderEnabled ? 'On' : 'Off',
              trailing: Switch(
                value: settings.dailyReminderEnabled,
                onChanged: (v) => context
                    .read<NotificationBloc>()
                    .add(ToggleDailyReminder(v)),
              ),
            ),
            if (settings.dailyReminderEnabled) ...[
              const Divider(height: 1),
              _SettingRow(
                icon: Icons.access_time_rounded,
                title: 'Reminder Time',
                subtitle:
                    _formatTime(settings.reminderHour, settings.reminderMinute),
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.reminderHour,
                      minute: settings.reminderMinute,
                    ),
                  );
                  if (t != null && context.mounted) {
                    context.read<NotificationBloc>().add(
                        UpdateReminderTime(hour: t.hour, minute: t.minute));
                  }
                },
              ),
            ],
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.summarize_outlined,
              title: 'End-of-Day Summary',
              subtitle: settings.summaryEnabled ? 'On' : 'Off',
              trailing: Switch(
                value: settings.summaryEnabled,
                onChanged: (v) => context
                    .read<NotificationBloc>()
                    .add(ToggleSummaryNotification(v)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
      );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted),
          ],
        ),
      ),
    );
  }
}
