import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../models/user_profile.dart';
import '../../utils/uuid_generator.dart';
import '../../theme/app_colors.dart';

class CreateProfileSheet extends StatefulWidget {
  const CreateProfileSheet({super.key});

  @override
  State<CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends State<CreateProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '10000');
  AccountType _accountType = AccountType.personal;
  String _colorHex = '#2D6BE4';
  bool _isLoading = false;

  final _colorOptions = [
    '#2D6BE4', '#9B59B6', '#2ECC71', '#E67E22',
    '#E74C3C', '#1ABC9C', '#F39C12', '#34495E',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is ProfilesLoaded) {
          Navigator.of(context).pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.loss),
          );
          setState(() => _isLoading = false);
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Create Profile', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                // Color picker
                Text('Avatar Color', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _colorOptions.map((hex) {
                    final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                    final selected = hex == _colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: color, width: 3)
                              : null,
                          boxShadow: selected
                              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Profile Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Starting Balance',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Balance required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Account Type', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                SegmentedButton<AccountType>(
                  segments: const [
                    ButtonSegment(value: AccountType.personal, label: Text('Personal')),
                    ButtonSegment(value: AccountType.propFirm, label: Text('Prop Firm')),
                  ],
                  selected: {_accountType},
                  onSelectionChanged: (s) => setState(() => _accountType = s.first),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final profile = UserProfile(
      id: UuidGenerator.generate(),
      name: _nameCtrl.text.trim(),
      avatarColorHex: _colorHex,
      balance: double.parse(_balanceCtrl.text),
      accountType: _accountType,
      dailyPermittedLossPercent: 5.0,
      maxPermittedLossPercent: 10.0,
      pinEnabled: false,
      biometricEnabled: false,
      lockAfterSeconds: 0,
      defaultMarkets: const [],
      calendarStartDay: CalendarStartDay.sunday,
      createdAt: DateTime.now(),
    );
    context.read<UserProfileBloc>().add(CreateProfile(profile));
  }
}
