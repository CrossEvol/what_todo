import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_widgets.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart'; // Import Label

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

void main() {
  setupTest();
  late MockTaskBloc mockTaskBloc;
  late MockHomeBloc mockHomeBloc;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
      ],
      child: TasksPage().withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    mockHomeBloc = MockHomeBloc();

    // Setup default states
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskInitial()]),
      initialState: TaskInitial(),
    );
    whenListen(
      mockHomeBloc,
      Stream.fromIterable([
        HomeInitial()
            .copyWith(filter: Filter().copyWith(status: TaskStatus.PENDING))
      ]),
      initialState: HomeInitial()
          .copyWith(filter: Filter().copyWith(status: TaskStatus.PENDING)),
    );
  });

  testWidgets('TasksPage should show loading indicator when loading',
      (WidgetTester tester) async {
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskLoading()]),
      initialState: TaskLoading(),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TasksPage should show empty message when no tasks',
      (WidgetTester tester) async {
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskLoaded([])]),
      initialState: TaskLoaded([]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No Task Added'), findsOneWidget);
  });

  testWidgets('TasksPage should display list of tasks when loaded',
      (WidgetTester tester) async {
    final tasks = [
      Task.create(
        title: "Test Task 1",
        projectId: 1,
        priority: PriorityStatus.PRIORITY_1,
      )
        ..id = 1
        ..projectName = "Test Project"
        ..projectColor = Colors.blue.value
        ..dueDate = DateTime.now().millisecondsSinceEpoch
        ..labelList = [
          Label.update(
              id: 1,
              name: "Label 1",
              colorCode: Colors.orange.value,
              colorName: "Orange")
        ],
      Task.create(
        title: "Test Task 2",
        projectId: 1,
        priority: PriorityStatus.PRIORITY_2,
      )
        ..id = 2
        ..projectName = "Test Project"
        ..projectColor = Colors.blue.value
        ..dueDate = DateTime.now().millisecondsSinceEpoch
        ..labelList = [
          Label.update(
              id: 1,
              name: "Label 1",
              colorCode: Colors.orange.value,
              colorName: "Orange")
        ],
    ];

    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskLoaded(tasks)]),
      initialState: TaskLoaded(tasks),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Test Task 1'), findsOneWidget);
    expect(find.text('Test Task 2'), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(2));
  });

  testWidgets('Should complete task when swiped left',
      (WidgetTester tester) async {
    final task = Task.create(
      title: "Test Task",
      projectId: 1,
      priority: PriorityStatus.PRIORITY_1,
    )
      ..id = 1
      ..projectName = "Test Project"
      ..projectColor = Colors.blue.value
      ..dueDate = DateTime.now().millisecondsSinceEpoch
      ..labelList = [
        Label.update(
            id: 1,
            name: "Label 1",
            colorCode: Colors.orange.value,
            colorName: "Orange")
      ];

    whenListen(
      mockTaskBloc,
      Stream.fromIterable([
        TaskLoaded([task])
      ]),
      initialState: TaskLoaded([task]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(Dismissible).first, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    expect(find.text('Task completed'), findsOneWidget);
  });

  testWidgets('Should delete task when swiped right',
      (WidgetTester tester) async {
    final task = Task.create(
      title: "Test Task",
      projectId: 1,
      priority: PriorityStatus.PRIORITY_1,
    )
      ..id = 1
      ..projectName = "Test Project"
      ..projectColor = Colors.blue.value
      ..dueDate = DateTime.now().millisecondsSinceEpoch
      ..labelList = [
        Label.update(
            id: 1,
            name: "Label 1",
            colorCode: Colors.orange.value,
            colorName: "Orange")
      ];

    whenListen(
      mockTaskBloc,
      Stream.fromIterable([
        TaskLoaded([task])
      ]),
      initialState: TaskLoaded([task]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible).first, const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    expect(find.text('Task deleted'), findsOneWidget);
  });

  testWidgets('Should refresh tasks when task status is updated',
      (WidgetTester tester) async {
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([
        TaskLoaded([]),
        TaskHasUpdated(),
      ]),
      initialState: TaskLoaded([]),
    );

    final homeState = HomeInitial().copyWith(filter: Filter.byToday());
    whenListen(
      mockHomeBloc,
      Stream.fromIterable([homeState]),
      initialState: homeState,
    );

    await tester.pumpWidget(createWidgetUnderTest());
  });
}
