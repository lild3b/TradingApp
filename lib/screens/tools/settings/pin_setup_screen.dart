import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/user_profile/user_profile_bloc.dart';
import '../../../theme/app_colors.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
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
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up PIN')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PinSetupSuccess) {
            // Update profile to mark PIN as enabled
            final profileState = context.read<UserProfileBloc>().state;
            if (profileState is ProfileSelected) {
              context.read<UserProfileBloc>().add(
                    UpdateProfile(
                        profileState.selectedProfile.copyWith(pinEnabled: true)),
                  );
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN set successfully'),
                backgroundColor: AppColors.profit,
              ),
            );
            context.pop();
          } else if (state is PinSetupError) {
            _shakeCtrl.forward(from: 0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.loss,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthUnlocking;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon header
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Create a PIN',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Your PIN will be required each time you open the app.\nUse 4–8 digits.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // New PIN field
                    SlideTransition(
                      position: _shakeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New PIN',
                              style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _newPinCtrl,
                            obscureText: _obscureNew,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            decoration: InputDecoration(
                              hintText: '••••',
                              counterText: '',
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'PIN required';
                              if (v.length < 4) return 'Minimum 4 digits';
                              if (!RegExp(r'^\d+$').hasMatch(v)) {
                                return 'Digits only';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Confirm PIN',
                              style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPinCtrl,
                            obscureText: _obscureConfirm,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            decoration: InputDecoration(
                              hintText: '••••',
                              counterText: '',
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your PIN';
                              }
                              if (v != _newPinCtrl.text) {
                                return 'PINs do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Set PIN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is! ProfileSelected) return;
    context.read<AuthBloc>().add(
          SetupPin(
            profileId: profileState.selectedProfile.id,
            pin: _newPinCtrl.text,
          ),
        );
  }
}
