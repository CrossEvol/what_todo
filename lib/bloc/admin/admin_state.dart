part of 'admin_bloc.dart';

sealed class AdminState extends Equatable {
  final List<LabelWithCount> labels;
  final List<ProjectWithCount> projects;
  final ColorPalette colorPalette;

  const AdminState({
    required this.labels,
    required this.projects,
    required this.colorPalette,
  });

  @override
  List<Object> get props => [labels, projects, colorPalette];

  AdminLoadedState copyWith(
      {List<LabelWithCount>? labels,
      List<ProjectWithCount>? projects,
      ColorPalette? colorPalette}) {
    return AdminLoadedState(
      labels: labels ?? this.labels,
      projects: projects ?? this.projects,
      colorPalette: colorPalette ?? this.colorPalette,
    );
  }
}

final class AdminInitialState extends AdminState {
  AdminInitialState(
      {required super.labels,
      required super.projects,
      required super.colorPalette});
}

final class AdminLoadedState extends AdminState {
  AdminLoadedState(
      {required super.labels,
      required super.projects,
      required super.colorPalette});
}
