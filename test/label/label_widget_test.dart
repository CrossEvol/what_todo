import 'package:flutter/material.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

LabelState defaultLabelState() {
  return LabelInitial();
}

void main() {
  setupTest();
  late MockLabelBloc mockLabelBloc;

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<LabelBloc>.value(
        value: mockLabelBloc,
        child: LabelPage().withLocalizedMaterialApp().withThemeProvider(),
      ),
    );
  }

  setUp(() {
    mockLabelBloc = MockLabelBloc();
  });

  Future<void> pumpLabelWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeLabelBlocStream(List<LabelState> states,
      {LabelState? initialState}) {
    whenListen(
      mockLabelBloc,
      Stream.fromIterable(states),
      initialState: initialState != null ? initialState : defaultLabelState(),
    );
  }

  testWidgets('LabelWidget should render properly with LabelInitial state',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([LabelInitial()]);
    await pumpLabelWidget(tester);

    expect(find.byType(LabelExpansionTileWidget), findsNothing);
    expect(find.byType(LabelPage), findsOneWidget);
    expect(find.text('Failed to load labels'), findsOneWidget);
  });

  testWidgets('LabelWidget should render properly with LabelLoading state',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([], initialState: LabelLoading());
    await pumpLabelWidget(tester);

    expect(find.byType(LabelExpansionTileWidget), findsNothing);
    expect(find.byType(LabelPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LabelWidget should display labels when available',
      (WidgetTester tester) async {
    final labelsLoaded = LabelsLoaded([
      Label.update(
          id: 1, name: 'Grey', colorCode: Colors.grey.value, colorName: 'Grey'),
      Label.update(
          id: 2, name: 'Red', colorCode: Colors.red.value, colorName: 'Red'),
    ]);

    arrangeLabelBlocStream([], initialState: labelsLoaded);
    await pumpLabelWidget(tester);
    await tester.pump(); // Add this to ensure widget tree is fully built

    // First verify the expansion tile is present
    expect(find.byType(LabelExpansionTileWidget), findsOneWidget);

    // Tap the expansion tile to expand it if needed
    await tester.tap(find.byType(LabelExpansionTileWidget));
    await tester.pumpAndSettle();

    // Now verify the individual label elements
    expect(find.text('@ Grey'), findsOneWidget);
    expect(find.text('@ Red'), findsOneWidget);

    // If LabelRow is a custom widget that wraps each label
    expect(find.byType(LabelRow), findsNWidgets(2));

    // Verify the drawer labels key
    expect(find.byKey(ValueKey(SideDrawerKeys.DRAWER_LABELS)), findsOneWidget);
  });
}
