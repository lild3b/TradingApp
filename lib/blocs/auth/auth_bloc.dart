import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';

part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<CheckLockStatus>(_onCheckLockStatus);
    on<UnlockWithPin>(_onUnlockWithPin);
    on<UnlockWithBiometric>(_onUnlockWithBiometric);
    on<LockProfile>(_onLockProfile);
    on<SetupPin>(_onSetupPin);
    on<ChangePin>(_onChangePin);
    on<DisablePin>(_onDisablePin);
    on<EnableBiometric>(_onEnableBiometric);
    on<DisableBiometric>(_onDisableBiometric);
  }

  final AuthRepository _repository;
  String? _currentProfileId;

  Future<void> _onCheckLockStatus(
      CheckLockStatus event, Emitter<AuthState> emit) async {
    _currentProfileId = event.profileId;
    final hasPin = await _repository.hasPinSet(event.profileId);
    if (hasPin) {
      final bioAvailable = await _repository.isBiometricAvailable();
      emit(AuthLocked(profileId: event.profileId, biometricAvailable: bioAvailable));
    } else {
      emit(AuthUnlocked(event.profileId));
    }
  }

  Future<void> _onUnlockWithPin(
      UnlockWithPin event, Emitter<AuthState> emit) async {
    emit(const AuthUnlocking());
    final verified = await _repository.verifyPin(event.profileId, event.pin);
    if (verified) {
      emit(AuthUnlocked(event.profileId));
    } else {
      final bioAvailable = await _repository.isBiometricAvailable();
      emit(AuthError('Incorrect PIN'));
      // Re-emit locked state so UI can shake and re-enable input
      emit(AuthLocked(profileId: event.profileId, biometricAvailable: bioAvailable));
    }
  }

  Future<void> _onUnlockWithBiometric(
      UnlockWithBiometric event, Emitter<AuthState> emit) async {
    emit(const AuthUnlocking());
    final authenticated = await _repository.authenticateWithBiometric();
    if (authenticated) {
      emit(AuthUnlocked(event.profileId));
    } else {
      final bioAvailable = await _repository.isBiometricAvailable();
      emit(AuthError('Biometric authentication failed'));
      emit(AuthLocked(profileId: event.profileId, biometricAvailable: bioAvailable));
    }
  }

  void _onLockProfile(LockProfile event, Emitter<AuthState> emit) {
    if (_currentProfileId != null) {
      emit(AuthLocked(profileId: _currentProfileId!));
    }
  }

  Future<void> _onSetupPin(
      SetupPin event, Emitter<AuthState> emit) async {
    try {
      await _repository.setPin(event.profileId, event.pin);
      emit(const PinSetupSuccess());
    } catch (e) {
      emit(PinSetupError(e.toString()));
    }
  }

  Future<void> _onChangePin(
      ChangePin event, Emitter<AuthState> emit) async {
    final verified = await _repository.verifyPin(event.profileId, event.oldPin);
    if (!verified) {
      emit(const PinSetupError('Incorrect current PIN'));
      return;
    }
    try {
      await _repository.setPin(event.profileId, event.newPin);
      emit(const PinSetupSuccess());
    } catch (e) {
      emit(PinSetupError(e.toString()));
    }
  }

  Future<void> _onDisablePin(
      DisablePin event, Emitter<AuthState> emit) async {
    await _repository.removePin(event.profileId);
    emit(AuthUnlocked(event.profileId));
  }

  Future<void> _onEnableBiometric(
      EnableBiometric event, Emitter<AuthState> emit) async {
    // Biometric is just a flag on the profile; actual auth handled separately
    emit(AuthUnlocked(event.profileId));
  }

  Future<void> _onDisableBiometric(
      DisableBiometric event, Emitter<AuthState> emit) async {
    emit(AuthUnlocked(event.profileId));
  }
}
