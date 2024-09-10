import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:test/test.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:mockito/mockito.dart';

import '../test_data.dart';

void main() {
  test('filterTodayTasks <- getTasks', () async {
    var fakeTaskDb = FakeTaskDb();
    var taskBloc = TaskBloc(fakeTaskDb);
    taskBloc.tasks.forEach((tasks) {
      tasks.forEach((task) {
        print(task.toMap());
      });
    });

    expect(
        (await taskBloc.tasks.first), unorderedEquals([testTask1, testTask2]));
  });

  test('filterTasksForNextWeek <- getTasks', () async {
    var fakeTaskDb = FakeTaskDb();
    var taskBloc = TaskBloc(fakeTaskDb);
    taskBloc.filterTasksForNextWeek();
    taskBloc.tasks.forEach((tasks) {
      tasks.forEach((task) {
        print(task.toMap());
      });
    });

    expect((await taskBloc.tasks.first),
        unorderedEquals([testTask1, testTask2, testTask3]));
  });

  test('filterByProject <- getTasksByProject', () async {
    var fakeTaskDb = FakeTaskDb();
    var taskBloc = TaskBloc(fakeTaskDb);

    taskBloc.filterByProject(1);
    expect((await taskBloc.tasks.first), unorderedEquals([testTask1]));

    taskBloc.filterByProject(2);
    expect((await taskBloc.tasks.first), unorderedEquals([testTask2]));

    taskBloc.filterByProject(3);
    expect((await taskBloc.tasks.first), unorderedEquals([testTask3]));
  });

  test('filterByLabel <- getTasksByLabel', () async {
    var fakeTaskDb = FakeTaskDb();
    var taskBloc = TaskBloc(fakeTaskDb);

    taskBloc.filterByLabel('Android');
    expectLater(
        (await taskBloc.tasks.first), unorderedEquals([testTask1, testTask3]));

    taskBloc.filterByLabel('Flutter');
    expectLater(
        (await taskBloc.tasks.first), unorderedEquals([testTask1, testTask2]));

    taskBloc.filterByLabel('React');
    expect(
        (await taskBloc.tasks.first), unorderedEquals([testTask2, testTask3]));
  });

  test('filterByStatus <- getTasks', () async {
    var fakeTaskDb = FakeTaskDb();
    var taskBloc = TaskBloc(fakeTaskDb);
    taskBloc.filterByStatus(TaskStatus.PENDING);

    expect((await taskBloc.tasks.first),
        unorderedEquals([testTask1, testTask2, testTask3]));

    taskBloc.filterByStatus(TaskStatus.COMPLETE);

    expect((await taskBloc.tasks.first), unorderedEquals([]));
  });
}

class FakeTaskDb extends Fake implements TaskDB {
  List<Task> taskList = List.empty(growable: true);

  @override
  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) async {
    if (!taskList.contains(testTask1)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask2)) {
      taskList.add(testTask2);
    }
    if (!taskList.contains(testTask3)) {
      taskList.add(testTask3);
    }

    if (startDate != 0) {
      taskList.removeWhere((t) => t.dueDate < startDate);
    }
    if (endDate != 0) {
      taskList.removeWhere((t) => t.dueDate > endDate);
    }

    if (taskStatus != null) {
      taskList.removeWhere((t) => t.tasksStatus != taskStatus);
    }

    return Future.value(taskList);
  }

  @override
  Future<List<Task>> getTasksByProject(int projectId,
      {TaskStatus? status}) async {
    if (!taskList.contains(testTask1)) {
      taskList.add(testTask1);
    }
    if (!taskList.contains(testTask2)) {
      taskList.add(testTask2);
    }
    if (!taskList.contains(testTask3)) {
      taskList.add(testTask3);
    }
    taskList.removeWhere((element) => element.projectId != projectId);
    return Future.value(taskList);
  }

  @override
  Future<List<Task>> getTasksByLabel(String labelName,
      {TaskStatus? status}) async {
    testTask1.labelList.addAll(['Android', 'Flutter']);
    if (!taskList.contains(testTask1)) {
      taskList.add(testTask1);
    }

    testTask2.labelList.addAll(['Flutter', 'React']);
    if (!taskList.contains(testTask2)) {
      taskList.add(testTask2);
    }

    testTask3.labelList.addAll(['Android', 'React']);
    if (!taskList.contains(testTask3)) {
      taskList.add(testTask3);
    }

    taskList.removeWhere((element) => !element.labelList.contains(labelName));
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
  Future updateTask(Task task, {List<int>? labelIDs}) async {
    throw UnimplementedError();
  }
}
