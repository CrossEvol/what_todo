part of 'project_bloc.dart';

abstract class ProjectState extends Equatable {
  final List<Project> projects = const [];

  const ProjectState();

  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<Project> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object> get props => [projects];
}

class ColorSelectionUpdated extends ProjectState {
  final ColorPalette colorPalette;

  const ColorSelectionUpdated(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object> get props => [message];
}

class ProjectExistenceChecked extends ProjectState {
  final bool exists;

  const ProjectExistenceChecked(this.exists);

  @override
  List<Object> get props => [exists];
}

class ProjectCreateSuccess extends ProjectState {
  const ProjectCreateSuccess();

  @override
  List<Object> get props => [];
}
