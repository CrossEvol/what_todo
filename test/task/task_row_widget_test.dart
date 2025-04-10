import 'package:flutter/material.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart'; // Import Label
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  Future<void> verifyPriorityColor(WidgetTester tester, PriorityStatus priority) async {
    var testTask = Task.update(
        id: 1, title: "Task One", projectId: 1, priority: priority);

    testTask.projectName = "Inbox";
    testTask.projectColor = Colors.grey.value;

    var wrapMaterialApp = TaskRow(testTask).wrapMaterialApp();
    await tester.pumpWidget(wrapMaterialApp);

    var container = tester.findWidgetByKey<Container>("taskPriority_1");
    expect(
        container.getBorderLeftColor(), priorityColor[testTask.priority.index]);
  }

  testWidgets("Task row smoke test without labels",
      (WidgetTester tester) async {
    //Set 15 august 2020 date for testing i.e Aug  15 in UI
    var dueDate = DateTime(2020, 8, 15);

    var testTask1 = Task.update(
        id: 1,
        title: "Task One",
        projectId: 1,
        priority: PriorityStatus.PRIORITY_3,
        dueDate: dueDate.millisecondsSinceEpoch);

    testTask1.projectName = "Inbox";
    testTask1.projectColor = Colors.grey.value;

    var wrapMaterialApp = TaskRow(testTask1).wrapMaterialApp();
    await tester.pumpWidget(wrapMaterialApp);

    expect(find.text(testTask1.title), findsOneWidget);
    expect(find.text(testTask1.projectName!), findsOneWidget);
    expect(find.text('Aug  15'), findsOneWidget);

    var container = tester.findWidgetByKey<Container>("taskPriority_1");
    expect(container.getBorderLeftColor(),
        priorityColor[testTask1.priority.index]);

    //Test no label is visible
    expect(find.byKey(ValueKey("taskLabels_1")), findsNothing);
  });

  testWidgets("Task row smoke test with labels", (WidgetTester tester) async {
    //Set 15 august 2020 date for testing i.e Aug  15 in UI
    var dueDate = DateTime(2020, 8, 15);

    var testTask1 = Task.update(
        id: 1,
        title: "Task One",
        projectId: 1,
        priority: PriorityStatus.PRIORITY_3,
        dueDate: dueDate.millisecondsSinceEpoch);

    testTask1.projectName = "Inbox";
    testTask1.projectColor = Colors.grey.value;
    testTask1.labelList = [
      Label.update(id: 1, name: "Android", colorCode: Colors.blue.value, colorName: "Blue"),
      Label.update(id: 2, name: "Flutter", colorCode: Colors.green.value, colorName: "Green"),
    ];

    var wrapMaterialApp = TaskRow(testTask1).wrapMaterialApp();
    await tester.pumpWidget(wrapMaterialApp);

    expect(find.text(testTask1.title), findsOneWidget);
    expect(find.text(testTask1.projectName!), findsOneWidget);
    expect(find.text('Aug  15'), findsOneWidget);

    //Test labels are visible by checking individual label texts and icons
    expect(find.text("Android"), findsOneWidget);
    expect(find.text("Flutter"), findsOneWidget);
    expect(find.byIcon(Icons.label), findsNWidgets(2)); // Check for 2 label icons
  });

  testWidgets("Task row smoke test with priorities color",
      (WidgetTester tester) async {
    await verifyPriorityColor(tester, PriorityStatus.PRIORITY_1);
    await verifyPriorityColor(tester, PriorityStatus.PRIORITY_2);
    await verifyPriorityColor(tester, PriorityStatus.PRIORITY_3);
    await verifyPriorityColor(tester, PriorityStatus.PRIORITY_4);
  });
}
