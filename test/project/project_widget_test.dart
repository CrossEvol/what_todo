import 'package:flutter/material.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';

import '../mocks/fake-bloc.dart';
import '../settings/settings_screen_test.dart';
import '../test_helpers.dart';

ProjectState defaultProjectState() {
  return ProjectInitial();
}

void main() {
  setupTest();
  late MockProjectBloc mockProjectBloc;
  late MockAdminBloc mockAdminBloc;
  late MockSettingsBloc mockSettingsBloc;

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
          BlocProvider<AdminBloc>.value(value: mockAdminBloc),
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        ],
        child: ProjectsExpansionTile().withLocalizedMaterialApp().withThemeProvider(),
      ),
    );
  }

  setUp(() {
    mockProjectBloc = MockProjectBloc();
    mockAdminBloc = MockAdminBloc();
    mockSettingsBloc = MockSettingsBloc();
  });

  Future<void> pumpProjectWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeProjectBlocStream(List<ProjectState> states,
      {ProjectState? initialState}) {
    whenListen(
      mockProjectBloc,
      Stream.fromIterable(states),
      initialState: initialState ?? defaultProjectState(),
    );
  }

  testWidgets('ProjectWidget should render properly with ProjectInitial state',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([ProjectInitial()]);
    await pumpProjectWidget(tester);

    expect(find.byType(ProjectExpansionTileWidget), findsNothing);
    expect(find.byType(ProjectsExpansionTile), findsOneWidget);
    expect(find.text('Failed to load projects'), findsOneWidget);
  });

  testWidgets('ProjectWidget should render properly with ProjectLoading state',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([], initialState: ProjectLoading());
    await pumpProjectWidget(tester);

    expect(find.byType(ProjectExpansionTileWidget), findsNothing);
    expect(find.byType(ProjectsExpansionTile), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ProjectWidget should display projects when available',
      (WidgetTester tester) async {
    // Setup mock states

    final projectsLoaded = ProjectsLoaded([
      Project(
        id: 1,
        name: "Project 1",
        colorValue: Colors.grey.value,
        colorName: "Grey",
      ),
      Project(
        id: 2,
        name: "Project 2",
        colorValue: Colors.red.value,
        colorName: "Red",
      ),
    ]);

    final projectsWithCount = [
      ProjectWithCount(
          id: 1,
          name: "Project 1",
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

    arrangeProjectBlocStream([], initialState: projectsLoaded);
    whenListen(mockSettingsBloc, Stream.fromIterable([defaultSettingState()]),
        initialState: defaultSettingState());
    var adminLoadedState = AdminLoadedState(
        labels: [],
        projects: projectsWithCount,
        colorPalette: ColorPalette.none());
    whenListen(mockAdminBloc, Stream.fromIterable([adminLoadedState]),
        initialState: adminLoadedState);
    await pumpProjectWidget(tester);
    await tester.pump();

    // Verify expansion tile is present
    expect(find.byType(ProjectExpansionTileWidget), findsOneWidget);

    // Tap to expand
    await tester.tap(find.byType(ProjectExpansionTileWidget));
    await tester.pumpAndSettle();

    // Verify project elements
    expect(find.text('Project 1'), findsOneWidget);
    expect(find.text('Project 2'), findsOneWidget);
    expect(find.byType(ProjectRow), findsNWidgets(2));

    // Verify the drawer projects key
    expect(
        find.byKey(ValueKey(SideDrawerKeys.DRAWER_PROJECTS)), findsOneWidget);

    // Verify add project button
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.byKey(ValueKey(SideDrawerKeys.ADD_PROJECT)), findsOneWidget);
  });
}
