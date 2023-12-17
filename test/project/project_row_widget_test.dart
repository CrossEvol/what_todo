import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

main() {

  testWidgets("Project Row Widget", (tester) async {
    final homeBloc = HomeBloc();
    final testProject = Project.update(
        id: 1, name: "Personal", colorName: "Red", colorCode: Colors.red.value);

    await tester
        .pumpWidget(ProjectRow(testProject).wrapScaffoldWithBloc(homeBloc));

    expect(find.text(testProject.name), findsOneWidget);

    final circleAvatar = tester.findWidgetByKey<CircleAvatar>("dot_Personal_1");
    expect(circleAvatar.backgroundColor!.value, testProject.colorValue);

    final spaceContainer =
        tester.findWidgetByKey<Container>("space_Personal_1");
    expect(spaceContainer.constraints!.widthConstraints().maxWidth, 24.0);
    expect(spaceContainer.constraints!.heightConstraints().maxHeight, 24.0);
  });

  testWidgets("Project Row Tap", (tester) async {
    var homeBloc = HomeBloc();
    var testProject = Project.update(
        id: 1, name: "Personal", colorName: "Red", colorCode: Colors.red.value);

    await tester
        .pumpWidget(ProjectRow(testProject).wrapScaffoldWithBloc(homeBloc));

    expect(homeBloc.title, emitsInOrder([testProject.name]));
    expect(homeBloc.filter, emitsInOrder([Filter.byProject(testProject.id!)]));
    await tester.tap(find.byKey(ValueKey("tile_Personal_1")));
  });

}
