part of 'user_profile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfiles extends UserProfileEvent {
  const LoadProfiles();
}

class SelectProfile extends UserProfileEvent {
  const SelectProfile(this.profileId);
  final String? profileId;

  @override
  List<Object?> get props => [profileId];
}

class CreateProfile extends UserProfileEvent {
  const CreateProfile(this.profile);
  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class UpdateProfile extends UserProfileEvent {
  const UpdateProfile(this.profile);
  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class DeleteProfile extends UserProfileEvent {
  const DeleteProfile(this.profileId);
  final String profileId;

  @override
  List<Object?> get props => [profileId];
}
