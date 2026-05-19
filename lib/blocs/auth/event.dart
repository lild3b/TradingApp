part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckLockStatus extends AuthEvent {
  const CheckLockStatus(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

class UnlockWithPin extends AuthEvent {
  const UnlockWithPin({required this.profileId, required this.pin});
  final String profileId;
  final String pin;

  @override
  List<Object?> get props => [profileId, pin];
}

class UnlockWithBiometric extends AuthEvent {
  const UnlockWithBiometric(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

class LockProfile extends AuthEvent {
  const LockProfile();
}

class SetupPin extends AuthEvent {
  const SetupPin({required this.profileId, required this.pin});
  final String profileId;
  final String pin;

  @override
  List<Object?> get props => [profileId, pin];
}

class ChangePin extends AuthEvent {
  const ChangePin({
    required this.profileId,
    required this.oldPin,
    required this.newPin,
  });
  final String profileId;
  final String oldPin;
  final String newPin;

  @override
  List<Object?> get props => [profileId, oldPin, newPin];
}

class DisablePin extends AuthEvent {
  const DisablePin(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

class EnableBiometric extends AuthEvent {
  const EnableBiometric(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

class DisableBiometric extends AuthEvent {
  const DisableBiometric(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}
