part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class ProfileLoadEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];

}

final class ProfileUpdateEvent extends ProfileEvent {
  final UserProfile profile;

  const ProfileUpdateEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
