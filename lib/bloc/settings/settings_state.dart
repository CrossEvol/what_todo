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
  final ResultStatus status;
  final String updatedKey;
  final Environment environment;
  final Language language;
  final int labelLen; // Added
  final int projectLen; // Added
  final Function(Locale) setLocale;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
    required this.enableImportExport,
    required this.confirmDeletion,
    required this.environment,
    required this.language,
    required this.labelLen, // Added
    required this.projectLen, // Added
    required this.setLocale,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
        enableImportExport,
        confirmDeletion,
        environment,
        language,
        labelLen, // Added
        projectLen, // Added
      ];

  SettingsState copyWith({
    bool? useCountBadges,
    ResultStatus? status,
    String? updatedKey,
    bool? enableImportExport,
    bool? confirmDeletion,
    Environment? environment,
    Language? language,
    int? labelLen, // Added
    int? projectLen, // Added
    Function(Locale)? setLocale,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
      enableImportExport: enableImportExport ?? this.enableImportExport,
      confirmDeletion: confirmDeletion ?? this.confirmDeletion,
      environment: environment ?? this.environment,
      language: language ?? this.language,
      labelLen: labelLen ?? this.labelLen, // Added
      projectLen: projectLen ?? this.projectLen, // Added
      setLocale: setLocale ?? this.setLocale,
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
          status == other.status &&
          updatedKey == other.updatedKey &&
          environment == other.environment &&
          language == other.language &&
          labelLen == other.labelLen && // Added
          projectLen == other.projectLen; // Added

  @override
  int get hashCode =>
      super.hashCode ^
      useCountBadges.hashCode ^
      enableImportExport.hashCode ^
      confirmDeletion.hashCode ^
      status.hashCode ^
      updatedKey.hashCode ^
      environment.hashCode ^
      language.hashCode ^
      labelLen.hashCode ^ // Added
      projectLen.hashCode; // Added
}
