part of 'project_bloc.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();
}

final class ProjectInitial extends ProjectState {
  @override
  List<Object> get props => [];
}
