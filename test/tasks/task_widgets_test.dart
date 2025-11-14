import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
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
import 'package:mocktail/mocktail.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

SettingsState defaultSettingState({bool confirmDeletion = false}) {
  return SettingsState(
    useCountBadges: false,
    enableImportExport: false,
    status: ResultStatus.none,
    updatedKey: '',
    environment: Environment.development,
    language: Language.english,
    setLocale: (Locale) {},
    labelLen: 8,
    projectLen: 8,
    confirmDeletion: confirmDeletion,
    enableNotifications: false,
    enableDailyReminder: false,
    enableGitHubExport: false,
  );
}

HomeState defaultHomeState({TaskStatus status = TaskStatus.PENDING}) {
  return HomeInitial().copyWith(
    filter: Filter().copyWith(status: status),
  );
}

TaskState defaultTaskState() {
  return TaskInitial();
}

class FakeTasksEvent extends Fake implements TaskEvent {}

class FakeHomeEvent extends Fake implements HomeEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTasksEvent());
    registerFallbackValue(FakeHomeEvent());
    registerFallbackValue(LoadSettingsEvent());
  });

  setupTest();
  late MockTaskBloc mockTaskBloc;
  late MockHomeBloc mockHomeBloc;
  late MockSettingsBloc mockSettingsBloc;

  // Helper function to create a test task
  Task createTestTask({
    int id = 1,
    String title = "Test Task",
    TaskStatus status = TaskStatus.PENDING,
  }) {
    return Task.create(
      title: title,
      projectId: 1,
      priority: PriorityStatus.PRIORITY_1,
    )
      ..id = id
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
  }

  // Helper function to create a widget under test
  Widget createTasksPageWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc)
      ],
      child: TasksPage().withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  // Helper function to create a PendingTaskListItem widget
  Widget createPendingTaskListItemWidget(
      {required Task task, required bool confirmDeletion}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
      ],
      child: PendingTaskListItem(
        task: task,
        index: 0,
        confirmDeletion: confirmDeletion,
      ).withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  // Helper function to create a CompletedTaskListItem widget
  Widget createCompletedTaskListItemWidget(
      {required Task task, required bool confirmDeletion}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
      ],
      child: CompletedTaskListItem(
        task: task,
        index: 0,
        confirmDeletion: confirmDeletion,
      ).withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    mockHomeBloc = MockHomeBloc();
    mockSettingsBloc = MockSettingsBloc();

    // Setup default states
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskInitial()]),
      initialState: TaskInitial(),
    );
    whenListen(
      mockHomeBloc,
      Stream.fromIterable([defaultHomeState()]),
      initialState: defaultHomeState(),
    );
    whenListen(
      mockSettingsBloc,
      Stream.fromIterable([defaultSettingState()]),
      initialState: defaultSettingState(),
    );
  });

  group('TasksPage Tests', () {
    testWidgets('TasksPage should show loading indicator when loading',
        (WidgetTester tester) async {
      whenListen(
        mockTaskBloc,
        Stream.fromIterable([TaskLoading()]),
        initialState: TaskLoading(),
      );

      await tester.pumpWidget(createTasksPageWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TasksPage should show empty message when no tasks',
        (WidgetTester tester) async {
      whenListen(
        mockTaskBloc,
        Stream.fromIterable([TaskLoaded([])]),
        initialState: TaskLoaded([]),
      );

      await tester.pumpWidget(createTasksPageWidget());
      await tester.pumpAndSettle();

      expect(find.text('No Task Added'), findsOneWidget);
    });

    testWidgets('TasksPage should display list of tasks when loaded',
        (WidgetTester tester) async {
      final tasks = [
        createTestTask(id: 1, title: "Test Task 1"),
        createTestTask(id: 2, title: "Test Task 2"),
      ];

      whenListen(
        mockTaskBloc,
        Stream.fromIterable([TaskLoaded(tasks)]),
        initialState: TaskLoaded(tasks),
      );

      await tester.pumpWidget(createTasksPageWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Task 1'), findsOneWidget);
      expect(find.text('Test Task 2'), findsOneWidget);
      expect(find.byType(Dismissible), findsNWidgets(2));
    });
  });

  group('PendingTaskListItem Tests', () {
    testWidgets('PendingTaskListItem should complete task when swiped left',
        (WidgetTester tester) async {
      final task = createTestTask();

      // Capture the event that's passed to the bloc
      final capturedEvents = <UpdateTaskStatusEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<UpdateTaskStatusEvent>())))
          .thenAnswer((invocation) {
        final event =
            invocation.positionalArguments.first as UpdateTaskStatusEvent;
        capturedEvents.add(event);
      });
      when(() => mockHomeBloc.add(any(that: isA<LoadTodayCountEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createPendingTaskListItemWidget(
        task: task,
        confirmDeletion: false,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Simulate the dismissible's onDismissed callback directly
      // This is more reliable than the drag in tests
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);
      dismissibleWidget.onDismissed!(DismissDirection.endToStart);

      // Pump to process the callback
      await tester.pump();

      // Verify the event was added to the bloc
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
      expect(capturedEvents.first.status, TaskStatus.COMPLETE);
    });

    testWidgets(
        'PendingTaskListItem should delete task when swiped right without confirmation',
        (WidgetTester tester) async {
      final task = createTestTask();

      // Capture the event that's passed to the bloc
      final capturedEvents = <DeleteTaskEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((invocation) {
        final event = invocation.positionalArguments.first as DeleteTaskEvent;
        capturedEvents.add(event);
      });
      when(() => mockHomeBloc.add(any(that: isA<LoadTodayCountEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createPendingTaskListItemWidget(
        task: task,
        confirmDeletion: false,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Simulate the dismissible's onDismissed callback directly
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);
      // For PendingTaskListItem, DELETE is a swipe from left to right (startToEnd)
      dismissibleWidget.onDismissed!(DismissDirection.startToEnd);

      // Pump to process the callback
      await tester.pump();

      // Verify the event was added to the bloc
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
    });

    testWidgets(
        'PendingTaskListItem should show confirmation dialog when swiped right with confirmDeletion=true',
        (WidgetTester tester) async {
      final task = createTestTask(title: "Task to delete");

      // Mock the showDialog function to return true (as if user confirmed)
      final capturedEvents = <DeleteTaskEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((invocation) {
        final event = invocation.positionalArguments.first as DeleteTaskEvent;
        capturedEvents.add(event);
      });
      when(() => mockHomeBloc.add(any(that: isA<LoadTodayCountEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createPendingTaskListItemWidget(
        task: task,
        confirmDeletion: true,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Get the dismissible widget
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);

      // Call confirmDismiss with startToEnd direction
      final _ = dismissibleWidget.confirmDismiss!(DismissDirection.startToEnd);
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Now manually call onDismissed since we've confirmed
      dismissibleWidget.onDismissed!(DismissDirection.startToEnd);
      await tester.pump();

      // Verify the delete event was sent
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
    });

    testWidgets(
        'PendingTaskListItem should not delete task when confirmation dialog is canceled',
        (WidgetTester tester) async {
      final task = createTestTask();

      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createPendingTaskListItemWidget(
        task: task,
        confirmDeletion: true,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Get the dismissible widget
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);

      // Call confirmDismiss with startToEnd direction
      final _ = dismissibleWidget.confirmDismiss!(DismissDirection.startToEnd);
      await tester.pump();

      // Verify the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify the dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Verify no delete event was sent
      verifyNever(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())));
    });
  });

  group('CompletedTaskListItem Tests', () {
    testWidgets(
        'CompletedTaskListItem should mark task as pending when swiped right',
        (WidgetTester tester) async {
      final task = createTestTask(status: TaskStatus.COMPLETE);

      // Capture the event that's passed to the bloc
      final capturedEvents = <UpdateTaskStatusEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<UpdateTaskStatusEvent>())))
          .thenAnswer((invocation) {
        final event =
            invocation.positionalArguments.first as UpdateTaskStatusEvent;
        capturedEvents.add(event);
      });

      await tester.pumpWidget(createCompletedTaskListItemWidget(
        task: task,
        confirmDeletion: false,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Simulate the dismissible's onDismissed callback directly
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);
      // For CompletedTaskListItem, UNDO (mark as pending) is a swipe from right to left (endToStart)
      dismissibleWidget.onDismissed!(DismissDirection.endToStart);

      // Pump to process the callback
      await tester.pump();

      // Verify the event was added to the bloc
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
      expect(capturedEvents.first.status, TaskStatus.PENDING);
    });

    testWidgets(
        'CompletedTaskListItem should delete task when swiped left without confirmation',
        (WidgetTester tester) async {
      final task = createTestTask(status: TaskStatus.COMPLETE);

      // Capture the event that's passed to the bloc
      final capturedEvents = <DeleteTaskEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((invocation) {
        final event = invocation.positionalArguments.first as DeleteTaskEvent;
        capturedEvents.add(event);
      });
      when(() => mockHomeBloc.add(any(that: isA<LoadTodayCountEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createCompletedTaskListItemWidget(
        task: task,
        confirmDeletion: false,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Simulate the dismissible's onDismissed callback directly
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);
      // For CompletedTaskListItem, DELETE is a swipe from left to right (startToEnd)
      dismissibleWidget.onDismissed!(DismissDirection.startToEnd);

      // Pump to process the callback
      await tester.pump();

      // Verify the event was added to the bloc
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
    });

    testWidgets(
        'CompletedTaskListItem should show confirmation dialog when swiped left with confirmDeletion=true',
        (WidgetTester tester) async {
      final task =
          createTestTask(status: TaskStatus.COMPLETE, title: "Completed task");

      // Capture the event that's passed to the bloc
      final capturedEvents = <DeleteTaskEvent>[];
      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((invocation) {
        final event = invocation.positionalArguments.first as DeleteTaskEvent;
        capturedEvents.add(event);
      });
      when(() => mockHomeBloc.add(any(that: isA<LoadTodayCountEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createCompletedTaskListItemWidget(
        task: task,
        confirmDeletion: true,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Get the dismissible widget
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);

      // Call confirmDismiss with endToStart direction
      final _ = dismissibleWidget.confirmDismiss!(DismissDirection.startToEnd);
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Now manually call onDismissed since we've confirmed
      // This should match the direction that triggers deletion, which is startToEnd for CompletedTaskListItem
      dismissibleWidget.onDismissed!(DismissDirection.startToEnd);
      await tester.pump();

      // Verify the delete event was sent
      expect(capturedEvents.length, 1);
      expect(capturedEvents.first.taskId, task.id);
    });

    testWidgets(
        'CompletedTaskListItem should not delete task when confirmation dialog is canceled',
        (WidgetTester tester) async {
      final task = createTestTask(status: TaskStatus.COMPLETE);

      when(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())))
          .thenAnswer((_) {});

      await tester.pumpWidget(createCompletedTaskListItemWidget(
        task: task,
        confirmDeletion: true,
      ));
      await tester.pumpAndSettle();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Get the dismissible widget
      final dismissibleWidget = tester.widget<Dismissible>(dismissible);

      // Call confirmDismiss with endToStart direction
      final _ = dismissibleWidget.confirmDismiss!(DismissDirection.startToEnd);
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify the dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Verify no delete event was sent
      verifyNever(() => mockTaskBloc.add(any(that: isA<DeleteTaskEvent>())));
    });
  });
}
