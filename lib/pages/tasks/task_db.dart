
import 'package:drift/drift.dart';
import 'package:flutter_app/dao/resource_db.dart' show ResourceDB;
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/labels/label.dart'
    as lb; // Use alias to avoid name clash if necessary
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/models/resource.dart';
import 'package:flutter_app/models/task_label_relation.dart';

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
      OrderingTerm.desc(_db.task.order),
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

  Future<Map<String, dynamic>> getExportDataV1() async {
    // Get all tasks with project and label information
    var query = _db.select(_db.task).join([
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
    ]);

    query.orderBy([
      OrderingTerm.desc(_db.task.order),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var result = await query.get();

    // Parse tasks with their labels
    Map<int, Map<String, dynamic>> taskMap = {};
    Map<int, Set<String>> taskLabels = {};

    for (var item in result) {
      var task = item.readTable(_db.task);
      var project = item.readTable(_db.project);
      var label = item.readTableOrNull(_db.label);

      if (!taskMap.containsKey(task.id)) {
        var map = task.toJson();
        taskMap[task.id] = {
          ...map,
          'projectName': project.name,
          // Convert DateTime to ISO string format to make it JSON serializable
          'dueDate': DateTime.parse(map['dueDate']).toIso8601String(),
          'labelNames': <String>[],
        };
        taskLabels[task.id] = <String>{};
      }

      if (label != null) {
        taskLabels[task.id]!.add(label.name);
      }
    }

    // Add label names to tasks
    for (var entry in taskLabels.entries) {
      taskMap[entry.key]!['labelNames'] = entry.value.toList();
    }

    // Get all projects
    final projects = await ProjectDB.get().getProjects();

    // Get all labels
    final labels = await LabelDB.get().getLabels();

    // Build the final export data
    return {
      '__v': 1,
      'projects': projects.map((p) => p.toMap()).toList(),
      'labels': labels.map((l) => l.toMap()).toList(),
      'tasks': taskMap.values.toList(),
    };
  }

  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.resource, _db.resource.taskId.equalsExp(_db.task.id)),
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
      OrderingTerm.desc(_db.task.order),
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
      var resource = item.readTableOrNull(_db.resource);

      if (!taskMap.containsKey(task.id)) {
        var map = task.toJson();
        var myTask = Task.fromMap({
          ...map,
          'dueDate': DateTime.parse(map['dueDate']).millisecondsSinceEpoch
        });
        myTask.projectName = project.name;
        myTask.projectColor = project.colorCode;
        myTask.labelList = [];
        myTask.resources = [];
        taskMap[task.id] = myTask;
      }

      if (label != null) {
        // Create a Label object and add it to the list
        final labelObject = lb.Label.fromMap({
          lb.Label.dbId: label.id,
          lb.Label.dbName: label.name,
          lb.Label.dbColorCode: label.colorCode,
          lb.Label.dbColorName: label.colorName,
        });
        taskMap[task.id]!.labelList.add(labelObject);
      }

      if (resource != null) {
        // Create a ResourceModel object and add it to the list
        final resourceObject = ResourceModel.fromMap({
          'id': resource.id,
          'path': resource.path,
          'taskId': resource.taskId,
          'createTime': resource.createTime.toIso8601String(),
        });
        taskMap[task.id]!.resources.add(resourceObject);
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
      leftOuterJoin(_db.resource, _db.resource.taskId.equalsExp(_db.task.id)),
    ]);

    query.where(_db.task.projectId.equals(projectId));

    if (status != null) {
      query.where(_db.task.status.equals(status.index));
    }

    query.orderBy([
      OrderingTerm.desc(_db.task.order),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var result = await query.get();
    return _bindData(result);
  }

  Future<List<Task>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    final tasksWithLabelQuery = _db.selectOnly(_db.taskLabel, distinct: true)
      ..addColumns([_db.taskLabel.taskId])
      ..join(
          [innerJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId))])
      ..where(_db.label.name.equals(labelName));

    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.resource, _db.resource.taskId.equalsExp(_db.task.id)),
    ]);

    query.where(_db.task.id.isInQuery(tasksWithLabelQuery));

    if (status != null) {
      query.where(_db.task.status.equals(status.index));
    }

    query.orderBy([
      OrderingTerm.desc(_db.task.order),
      OrderingTerm.desc(_db.task.dueDate),
    ]);

    var result = await query.get();
    return _bindData(result);
  }

  Future<bool> deleteTask(int taskID) async {
    return await _db.transaction(() async {
      var result = await (_db.delete(_db.task)
            ..where((tbl) => tbl.id.equals(taskID)))
          .go();
      if (result > 0) {
        await ResourceDB.get().deleteResourcesByTaskId(taskID);
      }
      return result > 0;
    });
  }

  Future<bool> updateTaskStatus(int taskID, TaskStatus status) async {
    var result = await (_db.update(_db.task)
          ..where((tbl) => tbl.id.equals(taskID)))
        .write(TaskCompanion(status: Value(status.index)));
    return result > 0;
  }

  Future<bool> updateOrder(
      {required int taskID, required int order, required bool findPrev}) async {
    var avgOrder = _db.task.order.avg();
    var result = await (_db.selectOnly(_db.task)
          ..addColumns([avgOrder])
          ..where(findPrev
              ? _db.task.order.isSmallerOrEqualValue(order)
              : _db.task.order.isBiggerOrEqualValue(order))
          ..limit(2))
        .getSingle();
    var avg = result.read(avgOrder);
    var newOrder = avg == null
        ? (findPrev ? order - 1000 : order + 1000)
        : (findPrev ? avg.floor() - 1 : avg.ceil() + 1);
    var i = await (_db.update(_db.task)..where((tbl) => tbl.id.equals(taskID)))
        .write(TaskCompanion(order: Value(newOrder)));
    if (i > 0) _resetOrderValues(newOrder);
    return i > 0;
  }

  Future<void> _resetOrderValues(int newOrder) async {
    final orderCount = _db.task.order.count();
    final count = (await (_db.selectOnly(_db.task)
              ..addColumns([orderCount])
              ..where(_db.task.order.equals(newOrder)))
            .getSingle())
        .read(orderCount);
    if (count == null) return;
    if (count == 1) return;
    _db.customStatement(r'''
      WITH numbered_rows AS (
        SELECT 
          id,
          ROW_NUMBER() OVER (ORDER BY `order`) AS row_num
        FROM task ORDER BY "order"
      )
      UPDATE task
      SET "order" = (
        SELECT row_num * 1000 
        FROM numbered_rows 
        WHERE numbered_rows.id = task.id
      );
      ''');
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
                dueDate:
                    Value(DateTime.fromMillisecondsSinceEpoch(task.dueDate)),
                priority: Value(task.priority.index),
                status: Value(task.tasksStatus!.index),
                order: Value(await _orderForNewTask())),
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

      // Assign unassigned resources to the newly created task
      if (id > 0) {
        final unassignedResources =
            await ResourceDB.get().getUnassignedResources();
        for (final resource in unassignedResources) {
          await ResourceDB.get().updateResourceTaskId(resource.id, id);
        }
      }

      return id;
    });
  }

  /// Inserts or replaces the task.
  Future<bool> updateTask(Task task, {List<int>? labelIDs}) async {
    var flag = await _db.transaction(() async {
      // update the record in Task Table
      var result = await (_db.update(_db.task)
            ..where((t) => t.id.equals(task.id!)))
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

      return result > 0;
    });

    return flag;
  }

  Future<int> _orderForNewTask() async {
    var query = _db.select(_db.task)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.order)])
      ..limit(1);
    var task = await query.getSingleOrNull();
    if (task == null) {
      return 1000;
    }
    return task.order + 1000;
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

  Future<Task?> getTaskById(int taskId) async {
    var query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.resource, _db.resource.taskId.equalsExp(_db.task.id)),
    ]);

    query.where(_db.task.id.equals(taskId));

    var result = await query.get();
    if (result.isNotEmpty) {
      final tasks = _bindData(result);
      return tasks.first;
    }
    return null;
  }

  Future<void> importDataV1(Map<String, dynamic> data) async {
    // Version check
    final version = data['__v'] as int? ?? 0;
    if (version != 1) {
      throw Exception('Unsupported data version: $version');
    }

    // Import projects first
    if (data.containsKey('projects')) {
      final projectMaps =
          (data['projects'] as List).cast<Map<String, dynamic>>();
      // final projectNames = projectMaps.map((p) => p['name'] as String).toSet();
      // await ProjectDB.get().importProjects(projectNames);
      for (var projectMap in projectMaps) {
        final project = Project.fromMap(projectMap);
        final projectDB = ProjectDB.get();
        // Only import if the label doesn't exist
        if (!await projectDB.isProjectExists(project)) {
          await projectDB.insertProject(project);
        }
      }
    }

    // Import labels
    if (data.containsKey('labels')) {
      final labelMaps = (data['labels'] as List).cast<Map<String, dynamic>>();
      for (var labelMap in labelMaps) {
        final label = lb.Label.fromMap(labelMap);
        final labelDB = LabelDB.get();
        // Only import if the label doesn't exist
        if (!await labelDB.isLabelExists(label)) {
          await labelDB.insertLabel(label);
        }
      }
    }

    // Import tasks
    if (data.containsKey('tasks')) {
      final taskMaps = (data['tasks'] as List).cast<Map<String, dynamic>>();

      // Build project name to ID mapping
      final projects = await ProjectDB.get().getProjects();
      final projectNameToId = {
        for (var project in projects) project.name: project.id
      };

      // Build label name to ID mapping
      final labels = await LabelDB.get().getLabels();
      final labelNameToId = {for (var label in labels) label.name: label.id};

      for (var taskMap in taskMaps) {
        // Check if task already exists
        var existingTasks = await (_db.select(_db.task)
              ..where((tbl) => tbl.title.equals(taskMap['title'])))
            .get();

        if (existingTasks.isEmpty) {
          // Get project ID from project name
          final projectName = taskMap['projectName'] as String;
          final projectId =
              projectNameToId[projectName] ?? 1; // Default to Inbox (ID 1)

          // Create task
          var task = Task.fromImport({
            ...taskMap,
            'projectId': projectId,
          });

          // Create the task and get its ID
          final taskId = await createTask(task);

          // Handle label associations if present
          if (taskMap.containsKey('labelNames') && taskId > 0) {
            final labelNames = (taskMap['labelNames'] as List).cast<String>();
            final labelIds = labelNames
                .map((name) => labelNameToId[name])
                .where((id) => id != null)
                .cast<int>()
                .toList();

            if (labelIds.isNotEmpty) {
              // Create task-label associations
              for (var labelId in labelIds) {
                await _db.into(_db.taskLabel).insertOnConflictUpdate(
                      TaskLabelCompanion(
                        taskId: Value(taskId),
                        labelId: Value(labelId),
                      ),
                    );
              }
            }
          }
        }
      }
    }
  }

  /// Batch insert tasks with transaction wrapper
  /// Returns list of inserted task IDs
  Future<List<int>> batchInsertTasks(List<Task> tasks) async {
    return await _db.transaction(() async {
      List<int> insertedIds = [];

      for (var task in tasks) {
        int id = await _db.into(_db.task).insert(
              TaskCompanion(
                id: task.id != null ? Value(task.id!) : Value.absent(),
                title: Value(task.title),
                projectId: Value(task.projectId),
                comment: Value(task.comment),
                dueDate:
                    Value(DateTime.fromMillisecondsSinceEpoch(task.dueDate)),
                priority: Value(task.priority.index),
                status: Value(task.tasksStatus!.index),
                order: Value(await _orderForNewTask()),
              ),
            );
        insertedIds.add(id);
      }

      return insertedIds;
    });
  }

  /// Check existing tasks by title for bulk existence checking
  /// Returns set of existing task titles
  Future<Set<String>> getExistingTaskTitles(List<String> titles) async {
    if (titles.isEmpty) return <String>{};

    final query = _db.select(_db.task)..where((tbl) => tbl.title.isIn(titles));
    final results = await query.get();
    return results.map((t) => t.title).toSet();
  }

  /// Get tasks by their titles
  /// Returns list of tasks that match the given titles
  Future<List<Task>> getTasksByTitles(List<String> titles) async {
    if (titles.isEmpty) return <Task>[];

    var query = _db.select(_db.task)
      ..where((t) => t.title.isIn(titles))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);

    var result = await query.get();

    return result.map((taskData) {
      var map = taskData.toJson();
      return Task.fromMap({
        ...map,
        'dueDate': DateTime.parse(map['dueDate']).millisecondsSinceEpoch
      });
    }).toList();
  }

  /// Batch insert task-label relationships with transaction wrapper
  Future<void> batchInsertTaskLabels(List<TaskLabelRelation> relations) async {
    if (relations.isEmpty) return;

    return await _db.transaction(() async {
      for (var relation in relations) {
        await _db.into(_db.taskLabel).insertOnConflictUpdate(
              TaskLabelCompanion(
                taskId: Value(relation.taskId),
                labelId: Value(relation.labelId),
              ),
            );
      }
    });
  }

  // TODO: will remove this method at last , currently for test convenience
  Future<Task?> getRandomTask() async {
    final query = _db.select(_db.task).join([
      leftOuterJoin(_db.taskLabel, _db.taskLabel.taskId.equalsExp(_db.task.id)),
      leftOuterJoin(_db.label, _db.label.id.equalsExp(_db.taskLabel.labelId)),
      innerJoin(_db.project, _db.project.id.equalsExp(_db.task.projectId)),
      leftOuterJoin(_db.resource, _db.resource.taskId.equalsExp(_db.task.id)),
    ])
      ..orderBy([OrderingTerm(expression: CustomExpression('RANDOM()'))])
      ..limit(1);

    final result = await query.get();
    final tasks = _bindData(result);
    return tasks.isNotEmpty ? tasks.first : null;
  }
}
