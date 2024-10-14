import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';

class TaskDB {
  static final TaskDB _taskDb = TaskDB._internal(AppDatabase());

  AppDatabase _db;

  //private internal constructor to make it singleton
  TaskDB._internal(this._db);

  static TaskDB get() {
    return _taskDb;
  }

  Future<int> countToday() async {
    final dateTime = DateTime.now();
    var yesterday = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var today = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59);

    var query = _db.selectOnly(_db.task);
    query.addColumns([_db.task.id.count()]);
    query.where(_db.task.dueDate.isBetweenValues(
        yesterday.millisecondsSinceEpoch, today.millisecondsSinceEpoch));
    var single = await query.getSingle();
    var count = single.read(_db.task.id.count()) ?? 0;
    return count;
  }

  Future<List<Task>> getTasks(
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

  Future<List<Task>> getTasksByProject(int projectId,
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

  Future<List<Task>> getTasksByLabel(String labelName,
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

  Future deleteTask(int taskID) async {
    await (_db.delete(_db.task)..where((tbl) => tbl.id.equals(taskID))).go();
  }

  Future updateTaskStatus(int taskID, TaskStatus status) async {
    await (_db.update(_db.task)..where((tbl) => tbl.id.equals(taskID)))
        .write(TaskCompanion(status: Value(status.index)));
  }

  /// Inserts or replaces the task.
  Future updateTask(Task task, {List<int>? labelIDs}) async {
    await _db.transaction(() async {
      int id = await _db.into(_db.task).insertOnConflictUpdate(
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
          await _db.into(_db.taskLabel).insertOnConflictUpdate(
                TaskLabelCompanion(
                  taskId: Value(id),
                  labelId: Value(labelId),
                ),
              );
        }
      }
    });
  }

  Future<void> updateExpiredTasks(int todayStartTime) async {
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
}
