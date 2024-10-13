import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/pages/tasks/bloc/my_add_task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../test_data.dart';
import '../test_helpers.dart';
import 'add_task_widget_test.mocks.dart';

class FakeTaskDb implements TaskDB {
  Task? task;
  List<int>? labelIds;

  Future updateTask(Task task, {List<int>? labelIDs}) async {
    this.task = task;
    this.labelIds = labelIDs!;
    return Future.value();
  }

  @override
  Future deleteTask(int taskID) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus? taskStatus}) {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasksByLabel(String labelName, {TaskStatus? status}) {
    // TODO: implement getTasksByLabel
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasksByProject(int projectId, {TaskStatus? status}) {
    // TODO: implement getTasksByProject
    throw UnimplementedError();
  }

  @override
  Future updateTaskStatus(int taskID, TaskStatus status) {
    // TODO: implement updateTaskStatus
    throw UnimplementedError();
  }

  @override
  Future<void> updateExpiredTasks(int todayStartTime) {
    // TODO: implement updateExpiredTasks
    throw UnimplementedError();
  }

  @override
  Future<int> countToday() {
    // TODO: implement count
    throw UnimplementedError();
  }
}

@GenerateMocks([ProjectDB, LabelDB])
void main() {
  group("Add Task", () {
    testWidgets("Add Task", (tester) async {
      final mockProjectDb = MockProjectDB();
      when(mockProjectDb.getProjects(isInboxVisible: true))
          .thenAnswer((_) async => [testProject1, testProject2, testProject3]);

      final mockLabelDb = MockLabelDB();
      when(mockLabelDb.getLabels()).thenAnswer(
          (_) => Future.value([testLabel1, testLabel2, testLabel3]));

      final fakeTaskDb = FakeTaskDb();

      final addTaskBloc = MyAddTaskBloc(fakeTaskDb, mockProjectDb, mockLabelDb);
      var addTaskWidget = AddTaskScreen().wrapMaterialAppWithBloc(addTaskBloc);
      await tester.pumpWidget(addTaskWidget);
      // await expectLater(
      //      find.byType(AddTaskScreen), matchesGoldenFile('add_task.png'));

      expect(find.text("Add Task"), findsOneWidget);
      var taskTitleKey = find.byKey(ValueKey("addTitle"));
      await tester.tap(taskTitleKey);
      await tester.pump();
      await tester.enterText(taskTitleKey, "My Task");
      await tester.pump();

      await tester.tap(find.text('Priority'));
      await tester.pump();
      await tester.tap(find.text('Priority 1'));
      await tester.pump();

      await tester.tap(find.byKey(ValueKey("addTask")));
      await tester.pump();

      expect(fakeTaskDb.task!.title, "My Task");
      expect(fakeTaskDb.task!.priority, PriorityStatus.PRIORITY_1);
      expect(fakeTaskDb.task!.projectId, Project.getInbox().id);
      expect(fakeTaskDb.labelIds, []);
    });
  });
}
