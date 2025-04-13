
import 'package:flutter/widgets.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

extension TestFinder on CommonFinders {
  Finder byValueKey(String key) {
    return find.byKey(ValueKey(key));
  }
}

extension TestWidgetTester on WidgetTester {
  Future<void> tapAndSettle(String key) async {
    await this.tap(find.byKey(ValueKey(key)));
    await pumpAndSettle();
  }
}

seedDataInDb() async {
  var projectDB = ProjectDB.get();
  await projectDB.upsertProject(testProject1);
  await projectDB.upsertProject(testProject2);
  await projectDB.upsertProject(testProject3);
  await projectDB.upsertProject(testProject4);

  var labelDB = LabelDB.get();
  await labelDB.insertLabel(testLabel1);
  await labelDB.insertLabel(testLabel2);
  await labelDB.insertLabel(testLabel3);

  var taskDB = TaskDB.get();
  await taskDB.updateTask(testTask1);
  await taskDB.updateTask(testTask2);
  await taskDB.updateTask(testTask3);
}

cleanDb() async {
  var projectDB = ProjectDB.get();
  List<Project> projects = await projectDB.getProjects(isInboxVisible: false);
  projects.forEach((project) {
    projectDB.deleteProject(project.id!);
  });

  var labelDB = LabelDB.get();
  List<Label> labels = await labelDB.getLabels();
  labels.forEach((label) {
    labelDB.deleteLabel(label.id!);
  });

  var taskDb = TaskDB.get();
  List<Task> tasks = await taskDb.getTasks();
  tasks.forEach((task) {
    taskDb.deleteTask(task.id!);
  });
}
