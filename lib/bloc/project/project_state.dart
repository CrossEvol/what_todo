part of 'project_bloc.dart';

abstract class ProjectState extends Equatable {
  final List<Project> projects = const [];
  final List<ProjectWithCount> projectsWithCount = const [];

  const ProjectState();

  @override
  List<Object> get props => [];

  int getProjectCount(projectID) =>
      projectsWithCount.where((p) => p.id == projectID).toList()[0].count;
}

class ProjectInitialState extends ProjectState {}

class ProjectLoadingState extends ProjectState {}

class ProjectsLoadedState extends ProjectState {
  final List<Project> projects;
  final List<ProjectWithCount> projectsWithCount;

  const ProjectsLoadedState(this.projects, this.projectsWithCount);

  @override
  List<Object> get props => [projects, projectsWithCount];
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
