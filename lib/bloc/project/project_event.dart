part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectEvent {
  final bool isInboxVisible;

  const LoadProjects({this.isInboxVisible = false});

  @override
  List<Object> get props => [isInboxVisible];
}

class CreateProject extends ProjectEvent {
  final Project project;
  final bool isInboxVisible;

  const CreateProject(this.project, {this.isInboxVisible = false});

  @override
  List<Object> get props => [project, isInboxVisible];
}

class UpdateColorSelection extends ProjectEvent {
  final ColorPalette colorPalette;

  const UpdateColorSelection(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class RefreshProjects extends ProjectEvent {
  final bool isInboxVisible;

  const RefreshProjects({this.isInboxVisible = false});

  @override
  List<Object> get props => [isInboxVisible];
}
