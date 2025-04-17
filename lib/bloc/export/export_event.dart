part of 'export_bloc.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

class ResetExportDataEvent extends ExportEvent {}

class LoadExportDataEvent extends ExportEvent {}

class DeleteProjectEvent extends ExportEvent {
  final int projectId;
  final bool deleteRelatedTasks;

  const DeleteProjectEvent({
    required this.projectId,
    required this.deleteRelatedTasks,
  });

  @override
  List<Object?> get props => [projectId, deleteRelatedTasks];
}

class DeleteLabelEvent extends ExportEvent {
  final int labelId;
  final bool deleteRelatedTasks;

  const DeleteLabelEvent({
    required this.labelId,
    required this.deleteRelatedTasks,
  });

  @override
  List<Object?> get props => [labelId, deleteRelatedTasks];
}

class DeleteTaskEvent extends ExportEvent {
  final int taskId;

  const DeleteTaskEvent({
    required this.taskId,
  });

  @override
  List<Object?> get props => [taskId];
}

class ExportDataEvent extends ExportEvent {
  final bool useNewFormat;

  const ExportDataEvent({
    required this.useNewFormat,
  });

  @override
  List<Object?> get props => [useNewFormat];
}

class ChangeTabEvent extends ExportEvent {
  final ExportTab tab;

  const ChangeTabEvent({
    required this.tab,
  });

  @override
  List<Object?> get props => [tab];
}
