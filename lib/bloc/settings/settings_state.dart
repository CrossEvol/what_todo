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
  final ResultStatus status;
  final String updatedKey;
  final Environment environment;
  final Language language;
  final Function(Locale) setLocale;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
    required this.enableImportExport,
    required this.environment,
    required this.language,
    required this.setLocale,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
        enableImportExport,
        environment,
        language,
      ];

  SettingsState copyWith({
    bool? useCountBadges,
    ResultStatus? status,
    String? updatedKey,
    bool? enableImportExport,
    Environment? environment,
    Language? language,
    Function(Locale)? setLocale,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
      enableImportExport: enableImportExport ?? this.enableImportExport,
      environment: environment ?? this.environment,
      language: language ?? this.language,
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
          status == other.status &&
          updatedKey == other.updatedKey &&
          environment == other.environment &&
          language == other.language;

  @override
  int get hashCode =>
      super.hashCode ^
      useCountBadges.hashCode ^
      enableImportExport.hashCode ^
      status.hashCode ^
      updatedKey.hashCode ^
      environment.hashCode ^
      language.hashCode;
}
