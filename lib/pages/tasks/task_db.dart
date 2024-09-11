import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/tasks/models/task_label.dart';

class TaskDB {
  static final TaskDB _taskDb = TaskDB._internal(AppDatabase());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  TaskDB._internal(this._appDatabase);

  static TaskDB get() {
    return _taskDb;
  }

  Future<List<Task>> getTasks({int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    var query = _appDatabase.select(_appDatabase.task).join([
      leftOuterJoin(_appDatabase.taskLabel,
          _appDatabase.taskLabel.taskId.equalsExp(_appDatabase.task.id)),
      leftOuterJoin(_appDatabase.label,
          _appDatabase.label.id.equalsExp(_appDatabase.taskLabel.labelId)),
      innerJoin(_appDatabase.project,
          _appDatabase.project.id.equalsExp(_appDatabase.task.projectId)),
    ]);

    if (startDate > 0 && endDate > 0) {
      query
          .where(_appDatabase.task.dueDate.isBetweenValues(startDate, endDate));
    }

    if (taskStatus != null) {
      query.where(_appDatabase.task.status.equals(taskStatus.index));
    }

    var result = await query.get();
    return _bindData(result);
  }

  List<Task> _bindData(List<TypedResult> result) {
    List<Task> tasks = [];
    for (var item in result) {
      var task = item.readTable(_appDatabase.task);
      var project = item.readTable(_appDatabase.project);
      var labelNames = item.readTableOrNull(_appDatabase.label)?.name;

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

  Future<List<Task>> getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    var query = _appDatabase.select(_appDatabase.task).join([
      leftOuterJoin(_appDatabase.taskLabel,
          _appDatabase.taskLabel.taskId.equalsExp(_appDatabase.task.id)),
      leftOuterJoin(_appDatabase.label,
          _appDatabase.label.id.equalsExp(_appDatabase.taskLabel.labelId)),
      innerJoin(_appDatabase.project,
          _appDatabase.project.id.equalsExp(_appDatabase.task.projectId)),
    ]);

    query.where(_appDatabase.task.projectId.equals(projectId));

    if (status != null) {
      query.where(_appDatabase.task.status.equals(status.index));
    }

    var result = await query.get();
    return _bindData(result);
  }

  Future<List<Task>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    var query = _appDatabase.select(_appDatabase.task).join([
      leftOuterJoin(_appDatabase.taskLabel,
          _appDatabase.taskLabel.taskId.equalsExp(_appDatabase.task.id)),
      leftOuterJoin(_appDatabase.label,
          _appDatabase.label.id.equalsExp(_appDatabase.taskLabel.labelId)),
      innerJoin(_appDatabase.project,
          _appDatabase.project.id.equalsExp(_appDatabase.task.projectId)),
    ]);

    if (status != null) {
      query.where(_appDatabase.task.status.equals(status.index));
    }

    query.where(_appDatabase.label.name.like('%$labelName%'));

    var result = await query.get();
    return _bindData(result);
  }

  Future deleteTask(int taskID) async {
    await (_appDatabase.delete(_appDatabase.task)
          ..where((tbl) => tbl.id.equals(taskID)))
        .go();
  }

  Future updateTaskStatus(int taskID, TaskStatus status) async {
    await (_appDatabase.update(_appDatabase.task)
          ..where((tbl) => tbl.id.equals(taskID)))
        .write(TaskCompanion(status: Value(status.index)));
  }

  /// Inserts or replaces the task.
  Future updateTask(Task task, {List<int>? labelIDs}) async {
    await _appDatabase.transaction(() async {
      int id = await _appDatabase.into(_appDatabase.task).insertOnConflictUpdate(
        TaskCompanion(
          id: task.id != null ? Value(task.id!) : Value.absent(),
          title: Value(task.title),
          projectId: Value(task.projectId),
          comment: Value(task.comment),
          dueDate: Value(task.dueDate),
          priority: Value(task.priority.index),
          status: Value(task.tasksStatus!.index),
        ),
      );

      if (id > 0 && labelIDs != null && labelIDs.isNotEmpty) {
        for (var labelId in labelIDs) {
          await _appDatabase.into(_appDatabase.taskLabel).insertOnConflictUpdate(
            TaskLabelCompanion(
              taskId: Value(id),
              labelId: Value(labelId),
            ),
          );
        }
      }
    });
  }
}
