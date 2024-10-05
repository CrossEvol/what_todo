import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

main() {

  testWidgets("Label Row Widget", (tester) async {
    final homeBloc = MyHomeBloc();
    var testLabel = Label.update(
        id: 1,
        name: "Android",
        colorName: "Green",
        colorCode: Colors.green.value);

    await tester
        .pumpWidget(LabelRow(testLabel).wrapScaffoldWithBloc(homeBloc));

    expect(find.text("@ ${testLabel.name}"), findsOneWidget);

    final iconLabel = tester.findWidgetByKey<Icon>("icon_Android_1");
    expect(iconLabel.color!.value, testLabel.colorValue);

    final spaceContainer = tester.findWidgetByKey<Container>("space_Android_1");
    expect(spaceContainer.constraints!.widthConstraints().maxWidth, 24.0);
    expect(spaceContainer.constraints!.heightConstraints().maxHeight, 24.0);
  });

  testWidgets("Label Row Tap", (tester) async {
    final homeBloc = MyHomeBloc();
    var testLabel = Label.update(
        id: 1,
        name: "Android",
        colorName: "Green",
        colorCode: Colors.green.value);

    await tester
        .pumpWidget(LabelRow(testLabel).wrapScaffoldWithBloc(homeBloc));

    expect(homeBloc.title, emitsInOrder(["@ ${testLabel.name}"]));
    expect(homeBloc.filter, emitsInOrder([Filter.byLabel(testLabel.name)]));
    await tester.tap(find.byKey(ValueKey("tile_Android_1")));
  });
}
