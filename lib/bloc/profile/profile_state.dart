part of 'profile_bloc.dart';

enum ProfileStateStatus { unknown, updateSuccess, updateFailure }

sealed class ProfileState extends Equatable {
  final ProfileStateStatus status = ProfileStateStatus.unknown;

  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

final class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  @override
  final ProfileStateStatus status;

  @override
  List<Object> get props => [profile, status];

  ProfileLoaded(this.profile, {this.status = ProfileStateStatus.unknown});
}
