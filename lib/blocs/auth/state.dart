part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLocked extends AuthState {
  const AuthLocked({required this.profileId, this.biometricAvailable = false});
  final String profileId;
  final bool biometricAvailable;

  @override
  List<Object?> get props => [profileId, biometricAvailable];
}

class AuthUnlocking extends AuthState {
  const AuthUnlocking();
}

class AuthUnlocked extends AuthState {
  const AuthUnlocked(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class PinSetupSuccess extends AuthState {
  const PinSetupSuccess();
}

class PinSetupError extends AuthState {
  const PinSetupError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
