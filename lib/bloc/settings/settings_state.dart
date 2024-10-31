part of 'settings_bloc.dart';

enum ResultStatus { success, failure, none }

enum Environment { production, development, test }

extension on String {
  toEnvironment() {
    EnumToString.fromString(Environment.values, this);
  }
}

class SettingsState extends Equatable {
  final bool useCountBadges;
  final bool enableImportExport;
  final ResultStatus status;
  final String updatedKey;
  final Environment environment;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
    required this.enableImportExport,
    required this.environment,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
        enableImportExport,
        environment,
      ];

  SettingsState copyWith({
    bool? useCountBadges,
    ResultStatus? status,
    String? updatedKey,
    bool? enableImportExport,
    Environment? environment,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
      enableImportExport: enableImportExport ?? this.enableImportExport,
      environment: environment ?? this.environment,
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
          environment == other.environment;

  @override
  int get hashCode =>
      super.hashCode ^
      useCountBadges.hashCode ^
      enableImportExport.hashCode ^
      status.hashCode ^
      updatedKey.hashCode ^
      environment.hashCode;
}
