part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TaskEvent {}

class LoadTasksByLabelEvent extends TaskEvent {
  final String labelName;
  final TaskStatus? status;

  LoadTasksByLabelEvent({
    required this.labelName,
    this.status,
  });
}

class LoadTasksByProjectEvent extends TaskEvent {
  final int projectId;
  final TaskStatus? status;

  LoadTasksByProjectEvent({
    required this.projectId,
    this.status,
  });
}

class PostponeTasksEvent extends TaskEvent {}

class PushAllToTodayEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;
  final List<int> labelIds;

  const AddTaskEvent({
    required this.task,
    required this.labelIds,
  });

  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  final List<int> labelIds;

  const UpdateTaskEvent({
    required this.task,
    required this.labelIds,
  });

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final int taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class UpdateTaskStatusEvent extends TaskEvent {
  final int taskId;
  final TaskStatus status;

  const UpdateTaskStatusEvent(this.taskId, this.status);

  @override
  List<Object> get props => [taskId, status];
}

class FilterTasksEvent extends TaskEvent {
  final Filter filter;

  const FilterTasksEvent({
    required this.filter,
  });
}
