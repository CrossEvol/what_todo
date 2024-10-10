part of 'admin_bloc.dart';

sealed class AdminState extends Equatable {
  final List<LabelWithCount> labels;

  final ColorPalette colorPalette;

  const AdminState({
    required this.labels,
    required this.colorPalette,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AdminState &&
          runtimeType == other.runtimeType &&
          labels == other.labels &&
          colorPalette == other.colorPalette;

  @override
  int get hashCode => super.hashCode ^ labels.hashCode ^ colorPalette.hashCode;
}

final class AdminInitialState extends AdminState {
  AdminInitialState({required super.labels, required super.colorPalette});

  @override
  List<Object> get props => [super.labels];
}

final class AdminLabelsLoadedState extends AdminState {
  AdminLabelsLoadedState({required super.labels, required super.colorPalette});

  @override
  List<Object> get props => [super.labels];

  AdminLabelsLoadedState copyWith(
      {List<LabelWithCount>? labels, ColorPalette? colorPalette}) {
    return AdminLabelsLoadedState(
        labels: labels ?? this.labels,
        colorPalette: colorPalette ?? this.colorPalette);
  }
}
