import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart'
    show ProjectBloc, ProjectsLoadedState;
import 'package:flutter_app/bloc/resource/resource_bloc.dart'
    show ResourceBloc, ResourceInitial;
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/cubit/comment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/pages/tasks/add_task.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/labels/label.dart';
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
  late MockResourceBloc mockResourceBloc;
  late MockCommentCubit mockCommentCubit;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<AdminBloc>.value(value: mockAdminBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
        BlocProvider<LabelBloc>.value(value: mockLabelBloc),
        BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
        BlocProvider<ResourceBloc>.value(value: mockResourceBloc),
        BlocProvider<CommentCubit>.value(value: mockCommentCubit),
      ],
      child: AddTaskScreen().withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    mockAdminBloc = MockAdminBloc();
    mockHomeBloc = MockHomeBloc();
    mockLabelBloc = MockLabelBloc();
    mockProjectBloc = MockProjectBloc();
    mockResourceBloc = MockResourceBloc();
    mockCommentCubit = MockCommentCubit();

    // Setup default states
    whenListen(
      mockTaskBloc,
      Stream.fromIterable([TaskInitial()]),
      initialState: TaskInitial(),
    );

    whenListen(
      mockAdminBloc,
      Stream.fromIterable([
        AdminLoadedState(
          colorPalette: ColorPalette.none(),
        )
      ]),
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

    final resourceState = ResourceInitial();
    whenListen(mockResourceBloc, Stream.fromIterable([resourceState]),
        initialState: resourceState);
    whenListen(mockCommentCubit, Stream.fromIterable([""]), initialState: "");
  });

  testWidgets('AddTaskScreen should render all initial elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify basic structure
    expect(find.byType(AddTaskScreen), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

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

    // Try to save without title
    await tester.enterText(find.byKey(ValueKey(AddTaskKeys.ADD_TITLE)), '');
    await tester.pump();

    // Tap the save button to trigger validation
    await tester.tap(find.byKey(ValueKey(AddTaskKeys.ADD_TASK)));
    await tester.pumpAndSettle();

    expect(find.text('Title Cannot be Empty'), findsOneWidget);
  });

  testWidgets('Should show project selection dialog',
      (WidgetTester tester) async {
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
        initialState: adminLoadedState);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap project selection
    await tester.tap(find.byKey(ValueKey("addProject")));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Select Project'), findsOneWidget);
    expect(find.text('Inbox'),
        findsNWidgets(2)); // one is in the selection, one is in the form
    expect(find.text('Project 2'), findsOneWidget);
  });

  testWidgets('Should show label selection dialog',
      (WidgetTester tester) async {
    final labels = [
      Label.update(
          id: 1,
          name: "Label 1",
          colorCode: Colors.blue.value,
          colorName: "Blue"),
      Label.update(
          id: 2,
          name: "Label 2",
          colorCode: Colors.red.value,
          colorName: "Red"),
    ];

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

    // Tap label selection
    await tester.tap(find.text('Labels'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Select Labels'), findsOneWidget);
    expect(find.text('Label 1'), findsOneWidget);
    expect(find.text('Label 2'), findsOneWidget);
  });

  testWidgets('Should show priority selection dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap priority selection
    await tester.tap(find.text('Priority'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Select Priority'), findsOneWidget);
    expect(find.text('Priority 1'), findsOneWidget);
    expect(find.text('Priority 2'), findsOneWidget);
    expect(find.text('Priority 3'), findsOneWidget);
    expect(find.text('Priority 4'),
        findsNWidgets(2)); // one is in the selection, one is in the form
  });
}
