import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:test/test.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:mockito/mockito.dart';

class FakeTaskDb extends Fake implements TaskDB {
  List<Tasks> taskList = List.empty(growable: true);

  @override
  Future<List<Tasks>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Tasks>> getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Tasks>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    throw UnimplementedError();
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
