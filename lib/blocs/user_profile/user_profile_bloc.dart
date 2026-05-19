import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../repositories/user_profile_repository.dart';

part 'event.dart';
part 'state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({required UserProfileRepository repository})
      : _repository = repository,
        super(const ProfilesLoading()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<SelectProfile>(_onSelectProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
  }

  final UserProfileRepository _repository;

  Future<void> _onLoadProfiles(
      LoadProfiles event, Emitter<UserProfileState> emit) async {
    emit(const ProfilesLoading());
    try {
      final profiles = await _repository.getAllProfiles();
      emit(ProfilesLoaded(profiles: profiles));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onSelectProfile(
      SelectProfile event, Emitter<UserProfileState> emit) async {
    final current = state;
    List<UserProfile> profiles = [];
    if (current is ProfilesLoaded) {
      profiles = current.profiles;
    } else if (current is ProfileSelected) {
      profiles = current.profiles;
    }

    if (event.profileId == null) {
      emit(ProfilesLoaded(profiles: profiles));
      return;
    }

    try {
      final profile = profiles.firstWhere((p) => p.id == event.profileId);
      emit(ProfileSelected(profiles: profiles, selectedProfile: profile));
    } catch (_) {
      emit(ProfileError('Profile not found'));
    }
  }

  Future<void> _onCreateProfile(
      CreateProfile event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.createProfile(event.profile);
      final profiles = await _repository.getAllProfiles();
      emit(ProfilesLoaded(profiles: profiles));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.updateProfile(event.profile);
      final profiles = await _repository.getAllProfiles();
      final current = state;
      if (current is ProfileSelected &&
          current.selectedProfile.id == event.profile.id) {
        emit(ProfileSelected(profiles: profiles, selectedProfile: event.profile));
      } else {
        emit(ProfilesLoaded(profiles: profiles));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteProfile(
      DeleteProfile event, Emitter<UserProfileState> emit) async {
    try {
      await _repository.deleteProfile(event.profileId);
      final profiles = await _repository.getAllProfiles();
      emit(ProfilesLoaded(profiles: profiles));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
