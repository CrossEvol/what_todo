import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/tasks/models/task_label.dart';
import 'package:sqflite/sqflite.dart';

class TaskDB {
  static final TaskDB _taskDb = TaskDB._internal(AppDatabase.get());

  AppDatabase _appDatabase;

  //private internal constructor to make it singleton
  TaskDB._internal(this._appDatabase);

  static TaskDB get() {
    return _taskDb;
  }

  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    var db = await _appDatabase.getDb();
    var whereClause = startDate > 0 && endDate > 0
        ? "WHERE Task.dueDate BETWEEN $startDate AND $endDate"
        : "";

    if (taskStatus != null) {
      var taskWhereClause =
          "Task.status = ${taskStatus.index}";
      whereClause = whereClause.isEmpty
          ? "WHERE $taskWhereClause"
          : "$whereClause AND $taskWhereClause";
    }

    var result = await db.rawQuery(
        'SELECT Task.*,project.name,project.colorCode,group_concat(label.name) as labelNames '
        'FROM Task LEFT JOIN taskLabel ON taskLabel.taskId=Task.id '
        'LEFT JOIN label ON label.id=taskLabel.labelId '
        'INNER JOIN project ON Task.projectId = project.id $whereClause GROUP BY Task.id ORDER BY Task.dueDate ASC;');

    return _bindData(result);
  }

  List<Task> _bindData(List<Map<String, dynamic>> result) {
    List<Task> tasks = [];
    for (Map<String, dynamic> item in result) {
      var myTask = Task.fromMap(item);
      myTask.projectName = item["name"];
      myTask.projectColor = item["colorCode"];
      var labelComma = item["labelNames"];
      if (labelComma != null) {
        myTask.labelList = labelComma.toString().split(",");
      }
      tasks.add(myTask);
    }
    return tasks;
  }

  Future<List<Task>> getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    var db = await _appDatabase.getDb();
    String whereStatus = status != null
        ? "AND Task.status=${status.index}"
        : "";
    var result = await db.rawQuery(
        'SELECT Task.*,project.name,project.colorCode,group_concat(label.name) as labelNames '
        'FROM Task LEFT JOIN taskLabel ON taskLabel.taskId=Task.id '
        'LEFT JOIN label ON label.id=taskLabel.labelId '
        'INNER JOIN project ON Task.projectId = project.id WHERE Task.projectId=$projectId $whereStatus GROUP BY Task.id ORDER BY Task.dueDate ASC;');

    return _bindData(result);
  }

  Future<List<Task>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    var db = await _appDatabase.getDb();
    String whereStatus = status != null
        ? "AND Task.status=${TaskStatus.PENDING.index}"
        : "";
    var result = await db.rawQuery(
        'SELECT Task.*,project.name,project.colorCode,group_concat(label.name) as labelNames '
        'FROM Task LEFT JOIN taskLabel ON taskLabel.taskId=Task.id '
        'LEFT JOIN label ON label.id=taskLabel.labelId '
        'INNER JOIN project ON Task.projectId = project.id $whereStatus GROUP BY Task.id having labelNames LIKE "%$labelName%" ORDER BY Task.dueDate ASC;');

    return _bindData(result);
  }

  Future deleteTask(int taskID) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          'DELETE FROM Task WHERE id=$taskID;');
    });
  }

  Future updateTaskStatus(int taskID, TaskStatus status) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      await txn.rawQuery(
          "UPDATE Task SET status = '${status.index}' WHERE id = '$taskID'");
    });
  }

  /// Inserts or replaces the task.
  Future updateTask(Task task, {List<int>? labelIDs}) async {
    var db = await _appDatabase.getDb();
    await db.transaction((Transaction txn) async {
      int id = await txn.rawInsert('INSERT OR REPLACE INTO '
          'Task(id,title,projectId,comment,dueDate,priority,status)'
          ' VALUES(${task.id}, "${task.title}", ${task.projectId},"${task.comment}", ${task.dueDate},${task.priority.index},${task.tasksStatus!.index})');
      if (id > 0 && labelIDs != null && labelIDs.length > 0) {
        labelIDs.forEach((labelId) {
          txn.rawInsert('INSERT OR REPLACE INTO '
              'taskLabel(id,taskId,labelId)'
              ' VALUES(null, $id, $labelId)');
        });
      }
    });
  }
}
