part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
}

final class LoadSettingsEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

final class ToggleUseCountBadgesEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

final class ToggleEnableImportExport extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

