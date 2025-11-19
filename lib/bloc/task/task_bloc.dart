import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/dao/resource_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'task_event.dart';

part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskDB _taskDB;
  final ILogger _logger = ILogger();
  final ResourceDB _resourceDB;

  TaskBloc(this._taskDB, this._resourceDB) : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskStatusEvent>(_onUpdateTaskStatus);
    on<LoadTasksByProjectEvent>(_onLoadTasksByProject);
    on<LoadTasksByLabelEvent>(_onLoadTasksByLabel);
    on<PostponeTasksEvent>(_onPostponeTasks);
    on<PushAllToTodayEvent>(_onPushAllToToday);
    on<FilterTasksEvent>(_onFilterTasks);
    on<ReOrderTasksEvent>(_reOrderTasks);
  }

  void _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskDB.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onPostponeTasks(
      PostponeTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final dateTime = DateTime.now();
      var flag = await _taskDB.updateExpiredTasks(
          DateTime(dateTime.year, dateTime.month, dateTime.day)
              .millisecondsSinceEpoch);
      if (flag) {
        final tasks = await _filterTodayTasks();
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onLoadTasksByProject(
      LoadTasksByProjectEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskDB.getTasksByProject(
        event.projectId,
        status: event.status,
      );
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onLoadTasksByLabel(
      LoadTasksByLabelEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks =
          await _taskDB.getTasksByLabel(event.labelName, status: event.status);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      await _taskDB.transaction(() async {
        try {
          final taskID = await _taskDB.createTask(
            event.task,
            labelIDs: event.labelIds,
          );
          final unassignedResources =
              await _resourceDB.getUnassignedResources();
          final resourceIds = unassignedResources.map((r) => r.id).toList();
          _logger.info('unassigned resourceIds: $resourceIds');
          for (final resourceID in resourceIds) {
            final b =
                await _resourceDB.updateResourceTaskId(resourceID, taskID);
            if (b) {
              _logger.info('assigned ${taskID} to ${resourceID} has succeed.');
            } else {
              _logger.info('assigned ${taskID} to ${resourceID} has failed.');
            }
          }
        } catch (e) {
          emit(TaskError(e.toString()));
          rethrow;
        }
      });
    }
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        await _taskDB.updateTask(event.task, labelIDs: event.labelIds);
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        var hasDeleted = await _taskDB.deleteTask(event.taskId);
        if (hasDeleted) {
          emit(TaskHasDeleted());
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  void _onUpdateTaskStatus(
      UpdateTaskStatusEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        var hasUpdated =
            await _taskDB.updateTaskStatus(event.taskId, event.status);
        if (hasUpdated) {
          emit(TaskHasUpdated());
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  void _onFilterTasks(FilterTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      var tasks = await _filterTasks(event.filter);
      if (!emit.isDone) {
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(TaskError(e.toString()));
      }
    }
  }

  Future<List<Task>> _filterTodayTasks({TaskStatus? taskStatus}) async {
    final dateTime = DateTime.now();

    var startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final int taskStartTime = startDate.millisecondsSinceEpoch;

    var endDate = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59);
    final int taskEndTime = endDate.millisecondsSinceEpoch;

    // Read all today's tasks from database
    var tasks = await _taskDB.getTasks(
        startDate: taskStartTime, endDate: taskEndTime, taskStatus: taskStatus);
    return tasks;
  }

  Future<List<Task>> _filterTasksForNextWeek({TaskStatus? taskStatus}) async {
    var dateTime = DateTime.now();
    var taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59)
            .millisecondsSinceEpoch;
    var taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
            .millisecondsSinceEpoch;
    // Read all next week tasks from database
    var tasks = await _taskDB.getTasks(
        startDate: taskStartTime, endDate: taskEndTime, taskStatus: taskStatus);
    return tasks;
  }

  Future<List<Task>> _filterByProject(int projectId, TaskStatus status) async {
    var tasks = await _taskDB.getTasksByProject(projectId, status: status);
    return tasks;
  }

  Future<List<Task>> _filterByLabel(
    String labelName,
    TaskStatus status,
  ) async {
    var tasks = await _taskDB.getTasksByLabel(labelName, status: status);
    return tasks;
  }

  Future<List<Task>> _filterByStatus(
    TaskStatus status,
  ) async {
    var tasks = await _taskDB.getTasks(taskStatus: status);
    return tasks;
  }

  Future<List<Task>> _filterTasks(Filter _lastFilter) async {
    var taskStatus =
        _lastFilter.status != null ? _lastFilter.status! : TaskStatus.PENDING;

    switch (_lastFilter.filterStatus!) {
      case FilterStatus.BY_TODAY:
        return await _filterTodayTasks(taskStatus: taskStatus);
      case FilterStatus.BY_WEEK:
        return await _filterTasksForNextWeek(taskStatus: taskStatus);
      case FilterStatus.BY_LABEL:
        return await _filterByLabel(_lastFilter.labelName!, taskStatus);
      case FilterStatus.BY_PROJECT:
        return await _filterByProject(_lastFilter.projectId!, taskStatus);
      case FilterStatus.BY_STATUS:
        return await _filterByStatus(_lastFilter.status!);
    }
  }

  FutureOr<void> _onPushAllToToday(
      PushAllToTodayEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      var flag = await _taskDB.updateInboxTasksToToday();
      if (flag) {
        final tasks = await _filterTodayTasks();
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  FutureOr<void> _reOrderTasks(
      ReOrderTasksEvent event, Emitter<TaskState> emit) async {
    try {
      var oldTask = event.oldTask;
      var newTask = event.newTask;
      var oldOrder = oldTask.order;
      var newOrder = newTask.order;
      bool hasUpdated;
      if (oldOrder < newOrder) {
        hasUpdated = await _taskDB.updateOrder(
            taskID: oldTask.id!, order: newOrder, findPrev: false);
      } else {
        hasUpdated = await _taskDB.updateOrder(
            taskID: oldTask.id!, order: newOrder, findPrev: true);
      }
      if (hasUpdated) emit(TaskReOrdered());
    } catch (e) {
      _logger.error(e);
      emit(TaskError(e.toString()));
    }
  }
}
