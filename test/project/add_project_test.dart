import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/projects/add_project.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

ProjectState defaultProjectState() {
  return ProjectsLoaded(const []);
}

void main() async {
  setupTest();
  late MockProjectBloc mockProjectBloc;
  late MockHomeBloc mockHomeBloc;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectBloc>.value(value: mockProjectBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
      ],
      child: AddProjectPage().withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockProjectBloc = MockProjectBloc();
    mockHomeBloc = MockHomeBloc();
  });

  Future<void> pumpAddProjectWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeProjectBlocStream(List<ProjectState> states) {
    whenListen(
      mockProjectBloc,
      Stream.fromIterable(states),
      initialState: defaultProjectState(),
    );
  }

  testWidgets('AddProject should render properly', (WidgetTester tester) async {
    arrangeProjectBlocStream([defaultProjectState()]);
    await pumpAddProjectWidget(tester);

    expect(find.byType(AddProjectPage), findsOneWidget);
    expect(
        find.byKey(ValueKey(AddProjectKeys.TITLE_ADD_PROJECT)), findsOneWidget);
    expect(find.byKey(ValueKey(AddProjectKeys.TEXT_FORM_PROJECT_NAME)),
        findsOneWidget);
    expect(find.byKey(ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON)),
        findsOneWidget);
  });

  testWidgets('Should show error when submitting empty project name',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([defaultProjectState()]);
    await pumpAddProjectWidget(tester);

    await tester.tap(find.byKey(ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON)));
    await tester.pump();

    expect(find.text('Project name cannot be empty'), findsOneWidget);
  });

  testWidgets('Should create project when form is valid',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([defaultProjectState()]);
    await pumpAddProjectWidget(tester);

    await tester.enterText(
        find.byKey(ValueKey(AddProjectKeys.TEXT_FORM_PROJECT_NAME)),
        'Test Project');
    await tester.pump();

    await tester.tap(find.byKey(ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON)));
    await tester.pump();
  });

  testWidgets('Should show color selection options',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([defaultProjectState()]);
    await pumpAddProjectWidget(tester);

    final expansionTile = find.byType(CollapsibleExpansionTile);
    expect(expansionTile, findsOneWidget);

    await tester.tap(expansionTile);
    await tester.pump();

    // Verify color options are displayed
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('Should update color when new color is selected',
      (WidgetTester tester) async {
    arrangeProjectBlocStream([
      defaultProjectState(),
      ColorSelectionUpdated(ColorPalette("Red", Colors.red.value))
    ]);
    await pumpAddProjectWidget(tester);

    final expansionTile = find.byType(CollapsibleExpansionTile);
    await tester.tap(expansionTile);
    await tester.pump();

    // Tap the first color option
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
  });
}
