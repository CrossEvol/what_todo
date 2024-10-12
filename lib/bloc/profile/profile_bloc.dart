import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/profile/profile.dart';
import 'package:flutter_app/pages/profile/profile_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileDB _profileDB;

  ProfileBloc(this._profileDB) : super(ProfileInitial()) {
    on<ProfileLoadEvent>(_loadProfile);
    on<ProfileUpdateEvent>(_updateProfile);
  }

  FutureOr<void> _loadProfile(
      ProfileLoadEvent event, Emitter<ProfileState> emit) async {
    final userProfile = await _profileDB.findByID(1);
    if (userProfile != null) {
      emit(ProfileLoaded(userProfile));
    } else {
      logger.error('Can not find UserProfile#1');
    }
  }

  FutureOr<void> _updateProfile(
      ProfileUpdateEvent event, Emitter<ProfileState> emit) async {
    try {
      if (await _profileDB.updateOne(event.profile)) {
        emit(ProfileLoaded(event.profile,
            status: ProfileStateStatus.updateSuccess));
      }
    } catch (e) {
      logger.error('Failed to update profile: $e');
      emit(ProfileLoaded((state as ProfileLoaded).profile,
          status: ProfileStateStatus.updateFailure));
      // You might want to emit an error state here
    }
  }
}
