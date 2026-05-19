import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../theme/app_colors.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeCtrl;
  late Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= 8) return;
    setState(() => _pin += digit);
    if (_pin.length >= 4) _tryUnlock();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _tryUnlock() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLocked) {
      context.read<AuthBloc>().add(UnlockWithPin(profileId: authState.profileId, pin: _pin));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnlocked) {
              context.go('/dashboard');
            } else if (state is AuthError) {
              _shakeCtrl.forward(from: 0);
              setState(() => _pin = '');
            } else if (state is AuthLocked) {
              setState(() => _pin = '');
            }
          },
          builder: (context, authState) {
            final profileState = context.read<UserProfileBloc>().state;
            String profileName = '';
            String avatarColor = '#2D6BE4';
            bool biometricAvailable = false;

            if (authState is AuthLocked) {
              biometricAvailable = authState.biometricAvailable;
              if (profileState is ProfileSelected) {
                profileName = profileState.selectedProfile.name;
                avatarColor = profileState.selectedProfile.avatarColorHex;
              }
            }

            return Column(
              children: [
                const Spacer(),
                // Avatar
                _ProfileAvatar(name: profileName, colorHex: avatarColor),
                const SizedBox(height: 16),
                Text(
                  profileName.isEmpty ? 'Enter PIN' : 'Welcome back, $profileName',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PIN to continue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 36),
                // PIN dots
                SlideTransition(
                  position: _shakeAnim,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (i) {
                      final filled = i < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? theme.colorScheme.primary
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          border: filled
                              ? null
                              : Border.all(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
                // Keypad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: _Keypad(
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                    onBiometric: biometricAvailable
                        ? () {
                            if (authState is AuthLocked) {
                              context.read<AuthBloc>().add(
                                    UnlockWithBiometric(authState.profileId),
                                  );
                            }
                          }
                        : null,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.colorHex});
  final String name;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = AppColors.primary;
    }
    return CircleAvatar(
      radius: 44,
      backgroundColor: color.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.dmSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onDelete, this.onBiometric});
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    final digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return Column(
      children: [
        ...digits.map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((d) => _DigitButton(digit: d, onTap: () => onDigit(d)))
                  .toList(),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            onBiometric != null
                ? _IconButton(
                    icon: Icons.fingerprint_rounded,
                    onTap: onBiometric!,
                  )
                : const SizedBox(width: 72),
            _DigitButton(digit: '0', onTap: () => onDigit('0')),
            _IconButton(icon: Icons.backspace_outlined, onTap: onDelete),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.onTap});
  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }
}
