import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
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
    query.where(_db.task.dueDate.isBetweenValues(yesterday, today));
    var single = await query.getSingle();
    var count = single.read(_db.task.id.count()) ?? 0;
    return count;
  }

  Future<List<ExportTask>> getExports() async {
    var query = _db.select(_db.task).join([
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    query.orderBy([
      OrderingTerm.asc(_db.task.priority),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var result = await query.get();

    Map<int, ExportTask> taskMap = {};

    for (var item in result) {
      var task = item.readTable(_db.task);
      var project = item.readTable(_db.project);

      if (!taskMap.containsKey(task.id)) {
        var map = task.toJson();
        var myTask = ExportTask.fromMap({
          ...map,
          'projectName': project.name,
          'dueDate': DateTime.parse(map['dueDate'])
        });
        taskMap[task.id] = myTask;
      }
    }

    return taskMap.values.toList();
  }

  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
    ]);

    if (startDate > 0 && endDate > 0) {
      query.where(_db.task.dueDate.isBetweenValues(
          DateTime.fromMillisecondsSinceEpoch(startDate),
          DateTime.fromMillisecondsSinceEpoch(endDate)));
    }

    if (taskStatus != null) {
      query.where(_db.task.status.equals(taskStatus.index));
    }

    query.orderBy([
      OrderingTerm.asc(_db.task.priority),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var result = await query.get();
    return _bindData(result);
  }

  List<Task> _bindData(List<TypedResult> result) {
    Map<int, Task> taskMap = {};

    for (var item in result) {
      var task = item.readTable(_db.task);
      var project = item.readTable(_db.project);
      var label = item.readTableOrNull(_db.label);

      if (!taskMap.containsKey(task.id)) {
        var map = task.toJson();
        var myTask = Task.fromMap({
          ...map,
          'dueDate': DateTime.parse(map['dueDate']).millisecondsSinceEpoch
        });
        myTask.projectName = project.name;
        myTask.projectColor = project.colorCode;
        myTask.labelList = [];
        taskMap[task.id] = myTask;
      }

      if (label != null) {
        taskMap[task.id]!.labelList.add(label.name);
      }
    }

    return taskMap.values.toList();
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

    query.orderBy([
      OrderingTerm.asc(_db.task.priority),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

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
    query.orderBy([
      OrderingTerm.asc(_db.task.priority),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

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
  Future<int> createTask(Task task, {List<int>? labelIDs}) async {
    return await _db.transaction(() async {
      int id = await _db.into(_db.task).insert(
            TaskCompanion(
              id: task.id != null ? Value(task.id!) : Value.absent(),
              title: Value(task.title),
              projectId: Value(task.projectId),
              comment: Value(task.comment),
              dueDate: Value(DateTime.fromMillisecondsSinceEpoch(task.dueDate)),
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

      return id;
    });
  }

  /// Inserts or replaces the task.
  Future updateTask(Task task, {List<int>? labelIDs}) async {
    await _db.transaction(() async {
      // update the record in Task Table
      await (_db.update(_db.task)..where((t) => t.id.equals(task.id!)))
          .write(TaskCompanion(
        id: task.id != null ? Value(task.id!) : Value.absent(),
        title: Value(task.title),
        projectId: Value(task.projectId),
        comment: Value(task.comment),
        dueDate: Value(DateTime.fromMillisecondsSinceEpoch(task.dueDate)),
        priority: Value(task.priority.index),
        status: Value(task.tasksStatus!.index),
      ));

      // remove the outdated relationship and build up new relationship
      await (_db.delete(_db.taskLabel)
            ..where((tbl) => tbl.taskId.equals(task.id!)))
          .go();
      if (labelIDs != null && labelIDs.isNotEmpty) {
        for (var labelId in labelIDs) {
          await _db.into(_db.taskLabel).insertOnConflictUpdate(
                TaskLabelCompanion(
                  taskId: Value(task.id!),
                  labelId: Value(labelId),
                ),
              );
        }
      }
    });
  }

  Future<bool> updateExpiredTasks(int todayStartTime) async {
    final tomorrowStartTime = todayStartTime + Duration(days: 1).inMilliseconds;
    var query = _db.select(_db.task);
    query.where((tbl) => tbl.dueDate.isBetweenValues(
        DateTime.fromMillisecondsSinceEpoch(todayStartTime),
        DateTime.fromMillisecondsSinceEpoch(tomorrowStartTime)));
    var future = await query.get();
    if (future.length == 0) return true;

    var result = await (_db.update(_db.task)
          ..where((tbl) =>
              tbl.dueDate.isBetweenValues(
                  DateTime.fromMillisecondsSinceEpoch(todayStartTime),
                  DateTime.fromMillisecondsSinceEpoch(tomorrowStartTime)) &
              tbl.status.equals(TaskStatus.PENDING.index)))
        .write(TaskCompanion(
            dueDate:
                Value(DateTime.fromMillisecondsSinceEpoch(tomorrowStartTime))));
    return result > 0;
  }

  Future<bool> updateInboxTasksToToday() async {
    final inboxProject = Project.inbox();
    final projectID = _db.selectOnly(_db.project)
      ..addColumns([_db.project.id])
      ..where(_db.project.name.equals(inboxProject.name))
      ..limit(1);

    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var query = _db.select(_db.task)
      ..where((row) => row.projectId.equalsExp(subqueryExpression(projectID)));
    var records = await query.get();
    if (records.length == 0) return true;

    var result = await ((_db.update(_db.task)
          ..where(
              (tbl) => tbl.projectId.equalsExp(subqueryExpression(projectID))))
        .write(TaskCompanion(dueDate: Value(today))));
    return result > 0;
  }

  Future<void> importTasks(List<Map<String, dynamic>> taskMaps) async {
    for (var taskMap in taskMaps) {
      // Check if the task already exists by title
      var existingTasks = await (_db.select(_db.task)
            ..where((tbl) => tbl.title.equals(taskMap['title'])))
          .get();

      if (existingTasks.isEmpty) {
        // Create a new task if it doesn't exist
        var newTask = Task.fromImport(taskMap);
        await createTask(newTask);
      }
    }
  }
}
