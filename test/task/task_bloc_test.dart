import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:test/test.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:mockito/mockito.dart';

import '../test_data.dart';

class FakeTaskDb extends Fake implements TaskDB {
  List<Tasks> taskList = List.empty(growable: true);

  @override
  Future<List<Tasks>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    if (!taskList.contains(testTask1)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask2)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask3)) {
      taskList.add(testTask1);
    }
    return Future.value(taskList);
  }

  @override
  Future<List<Tasks>> getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    if (!taskList.contains(testTask1)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask2)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask3)) {
      taskList.add(testTask1);
    }
    taskList.removeWhere((element) => element.projectId != projectId);
    return Future.value(taskList);
  }

  @override
  Future<List<Tasks>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    if (!taskList.contains(testTask1)) {
      testTask1.labelList = ['Android'];
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask2)) {
      testTask2.labelList = ['Flutter'];
      taskList.add(testTask2);
    }
    if (!taskList.contains(testTask3)) {
      testTask3.labelList = ['React'];
      taskList.add(testTask1);
    }
    return Future.value(taskList);
  }

  @override
  Future deleteTask(int taskID) async {
    throw UnimplementedError();
  }

  @override
  Future updateTaskStatus(int taskID, TaskStatus status) async {
    throw UnimplementedError();
  }

  @override
  Future updateTask(Tasks task, {List<int>? labelIDs}) async {
    throw UnimplementedError();
  }
}
