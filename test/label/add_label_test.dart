import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/labels/add_label.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

LabelState defaultLabelState() {
  return LabelInitial(labels: [], labelsWithCount: []);
}

SettingsState defaultSettingState() {
  return SettingsState(
    useCountBadges: false,
    enableImportExport: false,
    status: ResultStatus.none,
    updatedKey: '',
    environment: Environment.development,
    language: Language.english,
    setLocale: (Locale) {},
    labelLen: 16,
    projectLen: 16,
    confirmDeletion: false,
    enableNotifications: false,
    enableDailyReminder: false,
    enableGitHubExport: false,
  );
}

void main() {
  setupTest();
  late MockLabelBloc mockLabelBloc;
  late MockHomeBloc mockHomeBloc;
  late MockSettingsBloc mockSettingsBloc;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LabelBloc>.value(value: mockLabelBloc),
        BlocProvider<HomeBloc>.value(value: mockHomeBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
      child: AddLabelPage().withLocalizedMaterialApp().withThemeProvider(),
    );
  }

  setUp(() {
    mockLabelBloc = MockLabelBloc();
    mockHomeBloc = MockHomeBloc();
    mockSettingsBloc = MockSettingsBloc();
  });

  Future<void> pumpAddLabelWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeLabelBlocStream(List<LabelState> states) {
    whenListen(
      mockLabelBloc,
      Stream.fromIterable(states),
      initialState: defaultLabelState(),
    );
  }

  void arrangeSettingsBlocStream(List<SettingsState> states) {
    whenListen(
      mockSettingsBloc,
      Stream.fromIterable(states),
      initialState: defaultSettingState(),
    );
  }

  testWidgets('AddLabelPage should render properly',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([defaultLabelState()]);
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpAddLabelWidget(tester);

    expect(find.byType(AddLabelPage), findsOneWidget);
    expect(find.byKey(ValueKey(AddLabelKeys.TITLE_ADD_LABEL)), findsOneWidget);
    expect(find.byKey(ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME)),
        findsOneWidget);
    expect(find.byKey(ValueKey(AddLabelKeys.ADD_LABEL_BUTTON)), findsOneWidget);
  });

  testWidgets('Should show error when submitting empty label name',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([defaultLabelState()]);
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpAddLabelWidget(tester);

    await tester.tap(find.byKey(ValueKey(AddLabelKeys.ADD_LABEL_BUTTON)));
    await tester.pump();

    expect(find.text('Label Cannot be empty'), findsOneWidget);
  });

  testWidgets('Should create label when form is valid',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([
      defaultLabelState(),
      ColorSelectionUpdated(
          colorPalette: ColorPalette("Blue", Colors.blue.value),
          labels: [],
          labelsWithCount: []),
      LabelExistenceChecked(
        exists: false,
        labels: [],
        labelsWithCount: [],
      ),
    ]);
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpAddLabelWidget(tester);

    await tester.enterText(
        find.byKey(ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME)), 'Test Label');
    await tester.pump();

    await tester.tap(find.byKey(ValueKey(AddLabelKeys.ADD_LABEL_BUTTON)));
    await tester.pump();
  });

  testWidgets('Should show error when label already exists',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([
      defaultLabelState(),
      ColorSelectionUpdated(
        labels: [],
        labelsWithCount: [],
        colorPalette: ColorPalette("Blue", Colors.blue.value),
      ),
      LabelExistenceChecked(
        exists: true,
        labels: [],
        labelsWithCount: [],
      ),
    ]);
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpAddLabelWidget(tester);

    await tester.enterText(
        find.byKey(ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME)),
        'Existing Label');
    await tester.pump();

    await tester.tap(find.byKey(ValueKey(AddLabelKeys.ADD_LABEL_BUTTON)));
    await tester.pump();

    expect(find.text('Label already exists'), findsOneWidget);
  });

  testWidgets('Should update color selection when color is picked',
      (WidgetTester tester) async {
    arrangeLabelBlocStream([
      defaultLabelState(),
      ColorSelectionUpdated(
          labels: [],
          labelsWithCount: [],
          colorPalette: ColorPalette("Blue", Colors.blue.value)),
    ]);
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpAddLabelWidget(tester);

    // Find and tap the expansion tile
    await tester.tap(find.byType(CollapsibleExpansionTile));
    await tester.pump();

    // Find and tap a color option
    await tester.tap(find.text('Blue').first);
    await tester.pump();
  });
}
