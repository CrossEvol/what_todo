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

final class ToggleEnvironment extends SettingsEvent {
  final Environment environment;

  @override
  List<Object?> get props => [environment];

  const ToggleEnvironment({
    required this.environment,
  });
}

final class ToggleLanguage extends SettingsEvent {
  final Language language;

  const ToggleLanguage({required this.language});

  @override
  List<Object?> get props => [language];
}

final class AddSetLocaleFunction extends SettingsEvent {
  final Function(Locale) setLocale;

  const AddSetLocaleFunction({required this.setLocale});

  @override
  List<Object?> get props => [];
}
