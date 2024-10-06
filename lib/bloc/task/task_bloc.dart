import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';

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
    on<FilterTasksEvent>(_onFilterTasks);
  }

  void _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void _onPostponeTasks(PostponeTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _updateExpiredTasks(DateTime.now().millisecond);
      final tasks = await _getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _updateExpiredTasks(int todayStartTime) async {
    final tomorrowStartTime = todayStartTime + Duration(days: 1).inMilliseconds;
    var query = _db.select(_db.task);
    query.where((tbl) =>
        tbl.dueDate.isBetweenValues(todayStartTime, tomorrowStartTime));
    var future = await query.get();

    await (_db.update(_db.task)
          ..where((tbl) =>
              tbl.dueDate.isBetweenValues(todayStartTime, tomorrowStartTime) &
              tbl.status.equals(TaskStatus.PENDING.index)))
        .write(TaskCompanion(dueDate: Value(tomorrowStartTime)));
  }

  void _onLoadTasksByProject(
      LoadTasksByProjectEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks =
          await _getTasksByProject(event.projectId, status: event.status);
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
          await _getTasksByLabel(event.labelName, status: event.status);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<List<Task>> _getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    if (startDate > 0 && endDate > 0) {
      query.where(_db.task.dueDate.isBetweenValues(startDate, endDate));
    }

    if (taskStatus != null) {
      query.where(_db.task.status.equals(taskStatus.index));
    }

    var result = await query.get();
    return _bindData(result);
  }

  List<Task> _bindData(List<TypedResult> result) {
    List<Task> tasks = [];
    for (var item in result) {
      var task = item.readTable(_db.task);
      var project = item.readTable(_db.project);
      var labelNames = item.readTableOrNull(_db.label)?.name;

      var myTask = Task.fromMap(task.toJson());
      myTask.projectName = project.name;
      myTask.projectColor = project.colorCode;
      if (labelNames != null) {
        myTask.labelList = [labelNames];
      }
      tasks.add(myTask);
    }
    return tasks;
  }

  Future<List<Task>> _getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    query.where(_db.task.projectId.equals(projectId));

    if (status != null) {
      query.where(_db.task.status.equals(status.index));
    }

    var result = await query.get();
    return _bindData(result);
  }

  Future<List<Task>> _getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    if (status != null) {
      query.where(_db.task.status.equals(status.index));
    }

    query.where(_db.label.name.like('%$labelName%'));

    var result = await query.get();
    return _bindData(result);
  }

  void _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        await _taskDB.updateTask(event.task);
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        await _taskDB.updateTask(event.task);
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    }
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        await _taskDB.deleteTask(event.taskId);
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
        await _taskDB.updateTaskStatus(event.taskId, event.status);
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
    var tasks = await _getTasks(
        startDate: taskStartTime,
        endDate: taskEndTime,
        taskStatus: TaskStatus.PENDING);
    return tasks;
  }

  Future<List<Task>> _filterTasksForNextWeek() async {
    var dateTime = DateTime.now();
    var taskStartTime = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .millisecondsSinceEpoch;
    var taskEndTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
            .millisecondsSinceEpoch;
    // Read all next week tasks from database
    var tasks = await _getTasks(
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
}
