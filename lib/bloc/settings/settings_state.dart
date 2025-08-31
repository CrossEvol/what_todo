part of 'settings_bloc.dart';

enum ResultStatus { success, failure, none }

enum Environment { production, development, test }

enum Language { english, japanese, chinese }

extension on String {
  Environment toEnvironment() {
    return EnumToString.fromString(Environment.values, this) ??
        Environment.test;
  }

  Language toLanguage() {
    return EnumToString.fromString(Language.values, this) ?? Language.english;
  }
}

class SettingsState extends Equatable {
  final bool useCountBadges;
  final bool enableImportExport;
  final bool confirmDeletion;
  final bool enableNotifications;
  final bool enableDailyReminder;
  final ResultStatus status;
  final String updatedKey;
  final Environment environment;
  final Language language;
  final int labelLen; // Added
  final int projectLen; // Added
  final int reminderInterval;
  final Function(Locale) setLocale;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
    required this.enableImportExport,
    required this.confirmDeletion,
    required this.enableNotifications,
    required this.environment,
    required this.language,
    required this.labelLen, // Added
    required this.projectLen, // Added
    required this.setLocale,
    required this.enableDailyReminder,
    this.reminderInterval = 15,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
        enableImportExport,
        confirmDeletion,
        enableNotifications,
        environment,
        language,
        labelLen, // Added
        projectLen, // Added
        reminderInterval,
      ];

  SettingsState copyWith({
    bool? useCountBadges,
    ResultStatus? status,
    String? updatedKey,
    bool? enableImportExport,
    bool? confirmDeletion,
    bool? enableNotifications,
    bool? enableDailyReminder,
    Environment? environment,
    Language? language,
    int? labelLen, // Added
    int? projectLen, // Added
    int? reminderInterval,
    Function(Locale)? setLocale,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
      enableImportExport: enableImportExport ?? this.enableImportExport,
      confirmDeletion: confirmDeletion ?? this.confirmDeletion,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      environment: environment ?? this.environment,
      language: language ?? this.language,
      labelLen: labelLen ?? this.labelLen,
      // Added
      projectLen: projectLen ?? this.projectLen,
      // Added
      reminderInterval: reminderInterval ?? this.reminderInterval,
      setLocale: setLocale ?? this.setLocale,
      enableDailyReminder: enableDailyReminder ?? this.enableDailyReminder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SettingsState &&
          runtimeType == other.runtimeType &&
          useCountBadges == other.useCountBadges &&
          enableImportExport == other.enableImportExport &&
          confirmDeletion == other.confirmDeletion &&
          enableNotifications == other.enableNotifications &&
          enableDailyReminder == other.enableDailyReminder &&
          status == other.status &&
          updatedKey == other.updatedKey &&
          environment == other.environment &&
          language == other.language &&
          labelLen == other.labelLen &&
          projectLen == other.projectLen &&
          reminderInterval == other.reminderInterval &&
          setLocale == other.setLocale;

  @override
  int get hashCode => Object.hash(
      super.hashCode,
      useCountBadges,
      enableImportExport,
      confirmDeletion,
      enableNotifications,
      enableDailyReminder,
      status,
      updatedKey,
      environment,
      language,
      labelLen,
      projectLen,
      reminderInterval,
      setLocale);
}
