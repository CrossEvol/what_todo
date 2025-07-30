part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class LoadProjectsEvent extends ProjectEvent {
  final bool isInboxVisible;

  const LoadProjectsEvent({this.isInboxVisible = false});

  @override
  List<Object> get props => [isInboxVisible];
}

class CreateProjectEvent extends ProjectEvent {
  final Project project;
  final bool isInboxVisible;

  const CreateProjectEvent(this.project, {this.isInboxVisible = false});

  @override
  List<Object> get props => [project, isInboxVisible];
}

class UpdateColorSelectionEvent extends ProjectEvent {
  final ColorPalette colorPalette;

  const UpdateColorSelectionEvent(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class ProjectRemoveEvent extends ProjectEvent {
  final int projectID;

  const ProjectRemoveEvent({
    required this.projectID,
  });

  @override
  List<Object> get props => [projectID];
}

class ProjectUpdateEvent extends ProjectEvent {
  final Project project;

  const ProjectUpdateEvent({
    required this.project,
  });

  @override
  List<Object> get props => [project];
}

class RefreshProjectsEvent extends ProjectEvent {
  final bool isInboxVisible;

  const RefreshProjectsEvent({this.isInboxVisible = false});

  @override
  List<Object> get props => [isInboxVisible];
}
