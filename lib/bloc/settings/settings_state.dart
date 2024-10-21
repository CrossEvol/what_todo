part of 'settings_bloc.dart';

enum ResultStatus { success, failure, none }

class SettingsState extends Equatable {
  final bool useCountBadges;
  final bool enableImportExport;
  final ResultStatus status;
  final String updatedKey;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
    required this.enableImportExport,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
      ];

  SettingsState copyWith({
    bool? useCountBadges,
    ResultStatus? status,
    String? updatedKey,
    bool? enableImportExport,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
      enableImportExport: enableImportExport ?? this.enableImportExport,
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
          updatedKey == other.updatedKey;

  @override
  int get hashCode =>
      super.hashCode ^
      useCountBadges.hashCode ^
      enableImportExport.hashCode ^
      status.hashCode ^
      updatedKey.hashCode;
}
