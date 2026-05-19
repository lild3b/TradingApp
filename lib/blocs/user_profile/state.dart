part of 'user_profile_bloc.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class ProfilesLoading extends UserProfileState {
  const ProfilesLoading();
}

class ProfilesLoaded extends UserProfileState {
  const ProfilesLoaded({
    required this.profiles,
    this.selectedProfile,
  });

  final List<UserProfile> profiles;
  final UserProfile? selectedProfile;

  @override
  List<Object?> get props => [profiles, selectedProfile];
}

class ProfileSelected extends UserProfileState {
  const ProfileSelected({
    required this.profiles,
    required this.selectedProfile,
  });

  final List<UserProfile> profiles;
  final UserProfile selectedProfile;

  @override
  List<Object?> get props => [profiles, selectedProfile];
}

class ProfileError extends UserProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
