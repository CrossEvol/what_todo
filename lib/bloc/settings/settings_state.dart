part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final bool useCountBadges;

  const SettingsState({
    required this.useCountBadges,
  });

  @override
  List<Object> get props => [useCountBadges];

  SettingsState copyWith({
    bool? useCountBadges,
  }) {
    return SettingsState(
      useCountBadges: useCountBadges ?? this.useCountBadges,
    );
  }
}
