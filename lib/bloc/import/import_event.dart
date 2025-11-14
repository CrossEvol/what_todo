part of 'import_bloc.dart';

// Events
abstract class ImportEvent extends Equatable {
  const ImportEvent();

  @override
  List<Object> get props => [];
}

class ImportLoadDataEvent extends ImportEvent {
  final dynamic importData;

  const ImportLoadDataEvent(this.importData);

  @override
  List<Object> get props => [importData];
}

class ChangeImportTabEvent extends ImportEvent {
  final ImportTab tab;

  const ChangeImportTabEvent(this.tab);

  @override
  List<Object> get props => [tab];
}

class DeleteProjectEvent extends ImportEvent {
  final int projectIndex;
  final bool deleteRelatedTasks;

  const DeleteProjectEvent({
    required this.projectIndex,
    required this.deleteRelatedTasks,
  });

  @override
  List<Object> get props => [projectIndex, deleteRelatedTasks];
}

class DeleteLabelEvent extends ImportEvent {
  final int labelIndex;
  final bool deleteRelatedTasks;

  const DeleteLabelEvent({
    required this.labelIndex,
    required this.deleteRelatedTasks,
  });

  @override
  List<Object> get props => [labelIndex, deleteRelatedTasks];
}

class DeleteTaskEvent extends ImportEvent {
  final int taskIndex;

  const DeleteTaskEvent({required this.taskIndex});

  @override
  List<Object> get props => [taskIndex];
}

class ConfirmImportEvent extends ImportEvent {
  const ConfirmImportEvent();
}

class ImportInProgressEvent extends ImportEvent {
  final List<ProjectWithCount> projects;
  final List<LabelWithCount> labels;
  final List<Task> tasks;
  final List<ResourceModel> resources;
  final String? importPath;

  const ImportInProgressEvent({
    required this.projects,
    required this.labels,
    required this.tasks,
    required this.resources,
    this.importPath,
  });

  @override
  List<Object> get props =>
      [projects, labels, tasks, resources, importPath ?? ""];
}

class ImportFromGitHubEvent extends ImportEvent {
  final GitHubConfig gitHubConfig;

  const ImportFromGitHubEvent({
    required this.gitHubConfig,
  });

  @override
  List<Object> get props => [gitHubConfig];
}
