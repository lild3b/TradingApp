import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../models/user_profile.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import 'create_profile_sheet.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(const LoadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is ProfileSelected) {
              final profile = state.selectedProfile;
              if (profile.pinEnabled) {
                context.read<AuthBloc>().add(CheckLockStatus(profile.id));
                context.go('/lock');
              } else {
                context.read<AuthBloc>().add(CheckLockStatus(profile.id));
                context.go('/dashboard');
              }
            }
          },
          builder: (context, state) {
            return LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.candlestick_chart_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32),
                              const SizedBox(width: 12),
                              Text(
                                'Trading Journal',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a profile to continue',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is ProfilesLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is ProfilesLoaded || state is ProfileSelected) ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                        vertical: 8,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final profiles = state is ProfilesLoaded
                                ? state.profiles
                                : (state as ProfileSelected).profiles;
                            if (index == profiles.length) {
                              return _AddProfileCard(
                                onTap: () => _showCreateSheet(context),
                              );
                            }
                            return _ProfileCard(
                              profile: profiles[index],
                              onTap: () => context
                                  .read<UserProfileBloc>()
                                  .add(SelectProfile(profiles[index].id)),
                            );
                          },
                          childCount: (state is ProfilesLoaded
                                  ? state.profiles.length
                                  : (state as ProfileSelected).profiles.length) +
                              1,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            });
          },
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<UserProfileBloc>(),
        child: const CreateProfileSheet(),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onTap});
  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _parseColor(profile.avatarColorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: profile.accountType == AccountType.propFirm
                    ? AppColors.warningYellow.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                profile.accountType == AccountType.propFirm ? 'Prop Firm' : 'Personal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: profile.accountType == AccountType.propFirm
                      ? AppColors.warningYellow
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.currency(profile.balance),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (profile.pinEnabled)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.lock_outline_rounded, size: 14,
                    color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Profile',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
