import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart'
    show ProjectBloc, ProjectsLoadedState;
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/pages/tasks/edit_task.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/constants/keys.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

void main() {
  setupTest();
  late MockTaskBloc mockTaskBloc;
  late MockAdminBloc mockAdminBloc;
  late MockHomeBloc mockHomeBloc;
  late MockLabelBloc mockLabelBloc;
  late MockProjectBloc mockProjectBloc;
  late MockReminderBloc mockReminderBloc;
  late Task testTask;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<AdminBloc>.value(value: mockAdminBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
        BlocProvider<LabelBloc>.value(value: mockLabelBloc),
        BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
        BlocProvider<ReminderBloc>.value(
          value: mockReminderBloc,
        )
      ],
      child: EditTaskScreen(task: testTask)
          .withLocalizedMaterialApp()
          .withThemeProvider(),
    );
  }

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    mockAdminBloc = MockAdminBloc();
    mockHomeBloc = MockHomeBloc();
    mockLabelBloc = MockLabelBloc();
    mockProjectBloc = MockProjectBloc();
    mockReminderBloc = MockReminderBloc();

    testTask = Task.update(
      id: 1,
      title: "Test Task",
      projectId: 1,
      priority: PriorityStatus.PRIORITY_4,
      dueDate: DateTime.now().millisecondsSinceEpoch,
    );

    // Setup default states
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskInitial()]),
      initialState: TaskInitial(),
    );

    final adminLoadedState = AdminLoadedState(
      colorPalette: ColorPalette.none(),
    );
    whenListen(
      mockAdminBloc,
      Stream.fromIterable([
        AdminLoadedState(
          colorPalette: ColorPalette.none(),
        )
      ]),
      initialState: adminLoadedState,
    );

    whenListen(
      mockLabelBloc,
      Stream.fromIterable([
        LabelsLoaded(
          labels: [],
          labelsWithCount: [],
        )
      ]),
      initialState: LabelsLoaded(
        labels: [],
        labelsWithCount: [],
      ),
    );

    final homeState = HomeInitial().copyWith(
        title: "test",
        filter: Filter.byToday(),
        screen: SCREEN.EDIT_TASK,
        todayCount: 2);
    whenListen(
      mockHomeBloc,
      Stream.fromIterable([homeState]),
      initialState: homeState,
    );

    final reminderState = ReminderInitial();
    whenListen(mockReminderBloc, Stream.fromIterable([reminderState]),
        initialState: reminderState);

    final projectsWithCount = [
      ProjectWithCount(
          id: 1,
          name: "Inbox",
          colorCode: Colors.grey.value,
          colorName: "Grey",
          count: 1),
      ProjectWithCount(
          id: 2,
          name: "Project 2",
          colorCode: Colors.red.value,
          colorName: "Red",
          count: 2),
    ];

    final projectsLoaded = ProjectsLoadedState(
      [
        Project(
          id: 1,
          name: "Inbox",
          colorValue: Colors.grey.value,
          colorName: "Grey",
        ),
        Project(
          id: 2,
          name: "Project 2",
          colorValue: Colors.red.value,
          colorName: "Red",
        ),
      ],
      projectsWithCount,
    );

    whenListen(
      mockProjectBloc,
      Stream.fromIterable([projectsLoaded]),
      initialState: projectsLoaded,
    );
  });

  testWidgets(
      'EditTaskScreen should render all initial elements with task data',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify basic structure
    expect(find.byType(EditTaskScreen), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify task data is populated
    expect(find.text('Test Task'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Priority 4'), findsOneWidget);

    // Verify all ListTiles are present
    expect(find.byType(ListTile), findsExactly(7));
    expect(find.text('Project'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Labels'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Manage Resources'), findsOneWidget);
  });

  testWidgets('Should show validation error when title is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Clear the title
    await tester.enterText(find.byKey(ValueKey(EditTaskKeys.Edit_TITLE)), '');
    await tester.pump();

    // Tap the save button
    await tester.tap(find.byKey(ValueKey(EditTaskKeys.Edit_TASK)));
    await tester.pumpAndSettle();

    expect(find.text('Title Cannot be Empty'), findsOneWidget);
  });

  testWidgets(
      'Should show project selection dialog with current project selected',
      (WidgetTester tester) async {
    final projects = [
      ProjectWithCount(
        id: 1,
        name: "Inbox",
        colorCode: Colors.grey.value,
        colorName: "Grey",
        count: 0,
      ),
      ProjectWithCount(
        id: 2,
        name: "Project 2",
        colorCode: Colors.blue.value,
        colorName: "Blue",
        count: 0,
      ),
    ];

    whenListen(
      mockAdminBloc,
      Stream.fromIterable([
        AdminLoadedState(
          colorPalette: ColorPalette.none(),
        )
      ]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey("editProject")));
    await tester.pumpAndSettle();

    expect(find.text('Select Project'), findsOneWidget);
    expect(find.text('Inbox'), findsNWidgets(2));
    expect(find.text('Project 2'), findsOneWidget);
  });

  testWidgets('Should show label selection dialog with current labels selected',
      (WidgetTester tester) async {
    final labels = [
      Label.update(
        id: 1,
        name: "Label 1",
        colorCode: Colors.blue.value,
        colorName: "Blue",
      ),
      Label.update(
        id: 2,
        name: "Label 2",
        colorCode: Colors.red.value,
        colorName: "Red",
      ),
    ];

    // Assign a Label object instead of a string
    testTask.labelList = [labels[0]];

    whenListen(
      mockLabelBloc,
      Stream.fromIterable([
        LabelsLoaded(
          labels: labels,
          labelsWithCount: [],
        )
      ]),
      initialState: LabelsLoaded(
        labels: labels,
        labelsWithCount: [],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Label 1'), findsOneWidget);
    expect(find.text('Label 2'), findsNothing);
    await tester.tap(find.text('Labels'));
    await tester.pumpAndSettle();

    expect(find.text('Select Labels'), findsOneWidget);
    expect(find.text('Label 1'), findsNWidgets(2));
    expect(find.text('Label 2'), findsOneWidget);
  });

  testWidgets('Should update task when save button is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Update the title
    await tester.enterText(
        find.byKey(ValueKey(EditTaskKeys.Edit_TITLE)), 'Updated Task Title');
    await tester.pump();

    // Tap the save button
    await tester.tap(find.byKey(ValueKey(EditTaskKeys.Edit_TASK)));
    await tester.pumpAndSettle();
  });
}
