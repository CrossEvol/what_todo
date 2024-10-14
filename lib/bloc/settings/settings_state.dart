part of 'settings_bloc.dart';

enum ResultStatus { success, failure, none }

class SettingsState extends Equatable {
  final bool useCountBadges;
  final ResultStatus status;
  final String updatedKey;

  const SettingsState({
    required this.useCountBadges,
    required this.status,
    required this.updatedKey,
  });

  @override
  List<Object> get props => [
        useCountBadges,
        status,
        updatedKey,
      ];

  SettingsState copyWith(
      {bool? useCountBadges, ResultStatus? status, String? updatedKey}) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
      status: status ?? this.status,
      updatedKey: updatedKey ?? this.updatedKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SettingsState &&
          runtimeType == other.runtimeType &&
          useCountBadges == other.useCountBadges &&
          status == other.status &&
          updatedKey == other.updatedKey;

  @override
  int get hashCode =>
      super.hashCode ^
      useCountBadges.hashCode ^
      status.hashCode ^
      updatedKey.hashCode;
}
