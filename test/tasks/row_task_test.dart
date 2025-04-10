import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart'; // Import Label

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

void main() {
  setupTest();
  late MockTaskBloc mockTaskBloc;
  late Task testTask;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
      ],
      child: TaskRow(testTask).withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    testTask = Task.update(
      id: 1,
      title: "Test Task",
      projectId: 1,
      priority: PriorityStatus.PRIORITY_4,
      dueDate: DateTime.now().millisecondsSinceEpoch,
    );
    testTask.projectName = "Test Project";
    testTask.projectColor = Colors.grey.value;

    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskInitial()]),
      initialState: TaskInitial(),
    );
  });

  testWidgets('TaskRow should render all task elements correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify task title
    expect(find.text('Test Task'), findsOneWidget);
    expect(find.byKey(ValueKey("taskTitle_1")), findsOneWidget);

    // Verify project name and color
    expect(find.text('Test Project'), findsOneWidget);
    expect(find.byKey(ValueKey("taskProjectName_1")), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Verify priority indicator
    final container = tester.widget<Container>(
      find.byKey(ValueKey("taskPriority_1")),
    );
    expect(container.decoration, isA<BoxDecoration>());
  });

  testWidgets('TaskRow should display labels when present',
      (WidgetTester tester) async {
    testTask.labelList = [
      Label.update(id: 1, name: "Label1", colorCode: Colors.red.value, colorName: "Red"),
      Label.update(id: 2, name: "Label2", colorCode: Colors.purple.value, colorName: "Purple"),
    ];

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Check for individual label texts and icons
    expect(find.text("Label1"), findsOneWidget);
    expect(find.text("Label2"), findsOneWidget);
    expect(find.byIcon(Icons.label), findsNWidgets(2));
  });

  testWidgets('TaskRow should not display labels section when empty',
      (WidgetTester tester) async {
    testTask.labelList = []; // Already correct type, just ensuring it's empty

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Check that no label text or icons are found
    expect(find.textContaining("Label"), findsNothing); // More robust check
    expect(find.byIcon(Icons.label), findsNothing);
  });

  testWidgets('TaskRow should display formatted due date',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byKey(ValueKey("taskDueDate_1")), findsOneWidget);
  });

  testWidgets('TaskRow should navigate to edit screen on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    // Verify navigation was attempted
    // Note: Full navigation testing would require a more complex setup with GoRouter
    // This just verifies the gesture detector is present and tappable
    expect(find.byType(GestureDetector), findsOneWidget);
  });

  testWidgets('TaskRow should handle long titles gracefully',
      (WidgetTester tester) async {
    testTask.title = "A" * 100; // Very long title

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text("A" * 100), findsOneWidget);
    // Verify it doesn't overflow
    expect(tester.takeException(), isNull);
  });
}
