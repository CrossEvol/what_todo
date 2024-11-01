import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'task_event.dart';

part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskDB _taskDB;
  final _db = AppDatabase();

  TaskBloc(this._taskDB) : super(TaskInitial()) {
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
      try {
        await _taskDB.createTask(
          event.task,
          labelIDs: event.labelIds,
        );
      } catch (e) {
        emit(TaskError(e.toString()));
      }
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

  Future<List<Task>> _filterTodayTasks() async {
    final dateTime = DateTime.now();

    var startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final int taskStartTime = startDate.millisecondsSinceEpoch;

    var endDate = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59);
    final int taskEndTime = endDate.millisecondsSinceEpoch;

    // Read all today's tasks from database
    var tasks = await _taskDB.getTasks(
        startDate: taskStartTime,
        endDate: taskEndTime,
        taskStatus: TaskStatus.PENDING);
    return tasks;
  }

  Future<List<Task>> _filterTasksForNextWeek() async {
    var dateTime = DateTime.now();
    var taskStartTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59)
            .millisecondsSinceEpoch;
    var taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
            .millisecondsSinceEpoch;
    // Read all next week tasks from database
    var tasks = await _taskDB.getTasks(
        startDate: taskStartTime,
        endDate: taskEndTime,
        taskStatus: TaskStatus.PENDING);
    return tasks;
  }

  Future<List<Task>> _filterByProject(
    int projectId,
  ) async {
    var tasks =
        await _taskDB.getTasksByProject(projectId, status: TaskStatus.PENDING);
    return tasks;
  }

  Future<List<Task>> _filterByLabel(
    String labelName,
  ) async {
    var tasks =
        await _taskDB.getTasksByLabel(labelName, status: TaskStatus.COMPLETE);
    return tasks;
  }

  Future<List<Task>> _filterByStatus(
    TaskStatus status,
  ) async {
    var tasks = await _taskDB.getTasks(taskStatus: status);
    return tasks;
  }

  Future<List<Task>> _filterTasks(Filter _lastFilterStatus) async {
    switch (_lastFilterStatus.filterStatus!) {
      case FilterStatus.BY_TODAY:
        return await _filterTodayTasks();
      case FilterStatus.BY_WEEK:
        return await _filterTasksForNextWeek();
      case FilterStatus.BY_LABEL:
        return await _filterByLabel(_lastFilterStatus.labelName!);
      case FilterStatus.BY_PROJECT:
        return await _filterByProject(_lastFilterStatus.projectId!);
      case FilterStatus.BY_STATUS:
        return await _filterByStatus(_lastFilterStatus.status!);
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
      logger.error(e);
      emit(TaskError(e.toString()));
      print(e);
    }
  }
}
