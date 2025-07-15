import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/pages/settings/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:settings_ui/settings_ui.dart';

// Import your settings screen
import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

SettingsState defaultSettingState() {
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
    confirmDeletion: false,
    enableNotifications: false,
    enableDailyReminder: false,
  );
}

// can not track the trailing of SwitchTile
void main() async {
  setupTest();
  late MockSettingsBloc mockSettingsBloc;

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<SettingsBloc>.value(
        value: mockSettingsBloc,
        child: SettingsScreen().withThemeProvider(),
      ),
    );
  }

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
  });

  Future<void> pumpSettingsWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeSettingsBlocStream(List<SettingsState> states) {
    whenListen(
      mockSettingsBloc,
      Stream.fromIterable(states),
      initialState: defaultSettingState(),
    );
  }

  testWidgets('SettingsScreen should render properly',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpSettingsWidget(tester);

    // Add expectations for your initial settings UI
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byKey(ValueKey(SettingKeys.LANGUAGE)), findsOneWidget);
    expect(find.byKey(ValueKey(SettingKeys.Environment)), findsOneWidget);
    expect(find.byKey(ValueKey(SettingKeys.USE_COUNT_BADGES)), findsOneWidget);
    expect(
        find.byKey(ValueKey(SettingKeys.ENABLE_IMPORT_EXPORT)), findsOneWidget);
    expect(find.byKey(ValueKey(SettingKeys.ENABLE_DARK_MODE)), findsOneWidget);
    expect(
        find.byKey(ValueKey(SettingKeys.ENABLE_CUSTOM_THEME)), findsOneWidget);
  });

  testWidgets('SettingsScreen should display initial settings state',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([defaultSettingState()]);
    await pumpSettingsWidget(tester);

    // Add expectations for your initial settings UI
    final languageTile =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.LANGUAGE);
    expect((languageTile.value as Text).data, equals('English'));
    final environmentTile =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.Environment);
    expect((environmentTile.value as Text).data, equals('Development'));
    final useCountBadgesSwitch =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.USE_COUNT_BADGES);
    expect(useCountBadgesSwitch.initialValue, equals(false));
    final enableImportExportSwitch =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.ENABLE_IMPORT_EXPORT);
    expect(enableImportExportSwitch.initialValue, equals(false));
    final enableDarkModeSwitch =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.ENABLE_DARK_MODE);
    expect(enableDarkModeSwitch.initialValue, equals(false));
    final enableCustomThemeSwitch =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.ENABLE_CUSTOM_THEME);
    expect(enableCustomThemeSwitch.initialValue, equals(false));

    final labelMaxLengthTile =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.LABEL_LEN);
    expect((labelMaxLengthTile.value as Text).data, equals('8'));

    final projectMaxLengthTile =
        tester.findWidgetByKey<SettingsTile>(SettingKeys.PROJECT_LEN);
    expect((projectMaxLengthTile.value as Text).data, equals('8'));
  });

  testWidgets(
      'SettingsScreen should toggle useCountBadges when switch is pressed',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([
      defaultSettingState(),
      defaultSettingState().copyWith(useCountBadges: true),
    ]);
    await pumpSettingsWidget(tester);

    // initial false
    expect(
        tester
            .findWidgetByKey<SettingsTile>(SettingKeys.USE_COUNT_BADGES)
            .initialValue,
        equals(false));

    // set true
    await tester.tap(find.byKey(ValueKey(SettingKeys.USE_COUNT_BADGES)));
    await tester.pump();
    expect(
        tester
            .findWidgetByKey<SettingsTile>(SettingKeys.USE_COUNT_BADGES)
            .initialValue,
        equals(true));
  });

  testWidgets(
      'SettingsScreen should toggle enableImportExport when switch is pressed',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([
      defaultSettingState(),
      defaultSettingState().copyWith(enableImportExport: true),
    ]);
    await pumpSettingsWidget(tester);

    // initial false
    expect(
        tester
            .findWidgetByKey<SettingsTile>(SettingKeys.ENABLE_IMPORT_EXPORT)
            .initialValue,
        equals(false));

    // set true
    await tester.tap(find.byKey(ValueKey(SettingKeys.ENABLE_IMPORT_EXPORT)));
    await tester.pump();
    expect(
        tester
            .findWidgetByKey<SettingsTile>(SettingKeys.ENABLE_IMPORT_EXPORT)
            .initialValue,
        equals(true));
  });

  testWidgets(
      'SettingsScreen should update language when language option is selected',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([
      defaultSettingState(),
      defaultSettingState().copyWith(language: Language.chinese),
    ]);
    await pumpSettingsWidget(tester);

    // initial English
    expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.LANGUAGE).value)
                as Text)
            .data,
        equals('English'));

    await tester.tap(find.byKey(ValueKey(SettingKeys.LANGUAGE)));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byKey(ValueKey('lang-english')), findsOneWidget);
    expect(find.byKey(ValueKey('lang-japanese')), findsOneWidget);
    expect(find.byKey(ValueKey('lang-chinese')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('lang-chinese')));
    await tester.pump();

    // final Chinese
    expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.LANGUAGE).value)
                as Text)
            .data,
        equals('Chinese'));
  });

  testWidgets(
      'SettingsScreen should update environment when environment option is selected',
      (WidgetTester tester) async {
    arrangeSettingsBlocStream([
      defaultSettingState(),
      defaultSettingState().copyWith(environment: Environment.test),
    ]);
    await pumpSettingsWidget(tester);

    // initial English
    expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.Environment).value)
                as Text)
            .data,
        equals('Development'));

    await tester.tap(find.byKey(ValueKey(SettingKeys.Environment)));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byKey(ValueKey('env-production')), findsOneWidget);
    expect(find.byKey(ValueKey('env-development')), findsOneWidget);
    expect(find.byKey(ValueKey('env-test')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('env-test')));
    await tester.pump();

    // final Chinese
    expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.Environment).value)
                as Text)
            .data,
        equals('Test'));
  });

  testWidgets(
    'SettingsScreen should update label max length when a length option is selected',
    (WidgetTester tester) async {
      // Arrange: Set up the initial and updated states for the SettingsBloc
      arrangeSettingsBlocStream([
        defaultSettingState(),
        // Initial state
        defaultSettingState().copyWith(labelLen: 12),
        // Updated state after selection
      ]);
      await pumpSettingsWidget(tester);

      // Act & Assert: Verify initial state
      expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.LABEL_LEN).value)
                as Text)
            .data,
        equals('8'), // Assuming defaultSettingState has labelLen = 8
      );

      // Scroll to ensure the Label Max Length tile is visible
      await tester.ensureVisible(find.byKey(ValueKey(SettingKeys.LABEL_LEN)));
      await tester.pumpAndSettle(); // Wait for scrolling to complete

      // Tap the Label Max Length tile to open the dialog
      await tester.tap(find.byKey(ValueKey(SettingKeys.LABEL_LEN)));
      await tester.pumpAndSettle(); // Wait for dialog to appear

      // Verify the dialog appears with options
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.byKey(ValueKey('${SettingKeys.LABEL_LEN}-12')), findsOneWidget);

      // Tap the option for 12 characters
      await tester.tap(find.byKey(ValueKey('${SettingKeys.LABEL_LEN}-12')));
      await tester
          .pumpAndSettle(); // Wait for dialog to close and state to update

      // Verify the updated state
      expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.LABEL_LEN).value)
                as Text)
            .data,
        equals('12'),
      );
    },
  );

  testWidgets(
    'SettingsScreen should update project max length when a length option is selected',
    (WidgetTester tester) async {
      // Arrange: Set up the initial and updated states for the SettingsBloc
      arrangeSettingsBlocStream([
        defaultSettingState(),
        // Initial state
        defaultSettingState().copyWith(projectLen: 16),
        // Updated state after selection
      ]);
      await pumpSettingsWidget(tester);

      // Act & Assert: Verify initial state
      expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.PROJECT_LEN).value)
                as Text)
            .data,
        equals('8'), // Assuming defaultSettingState has projectLen = 8
      );

      // Scroll to ensure the Project Max Length tile is visible
      await tester.ensureVisible(find.byKey(ValueKey(SettingKeys.PROJECT_LEN)));
      await tester.pumpAndSettle(); // Wait for scrolling to complete

      // Tap the Project Max Length tile to open the dialog
      await tester.tap(find.byKey(ValueKey(SettingKeys.PROJECT_LEN)));
      await tester.pumpAndSettle(); // Wait for dialog to appear

      // Verify the dialog appears with options
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byKey(ValueKey('${SettingKeys.PROJECT_LEN}-16')),
          findsOneWidget);

      // Tap the option for 16 characters
      await tester.tap(find.byKey(ValueKey('${SettingKeys.PROJECT_LEN}-16')));
      await tester
          .pumpAndSettle(); // Wait for dialog to close and state to update

      // Verify the updated state
      expect(
        ((tester.findWidgetByKey<SettingsTile>(SettingKeys.PROJECT_LEN).value)
                as Text)
            .data,
        equals('16'),
      );
    },
  );

  testWidgets(
    'SettingsScreen should display and toggle confirm deletion setting',
    (WidgetTester tester) async {
      // Arrange: Set up the initial and updated states for the SettingsBloc
      arrangeSettingsBlocStream([
        defaultSettingState(),
        // Initial state (confirmDeletion is false by default)
        defaultSettingState().copyWith(confirmDeletion: true),
        // Updated state after toggling
      ]);
      await pumpSettingsWidget(tester);

      // Verify the Confirm Deletion tile is displayed
      expect(
          find.byKey(ValueKey(SettingKeys.CONFIRM_DELETION)), findsOneWidget);

      // Find the Confirm Deletion switch tile and verify initial state
      final confirmDeletionSwitch =
          tester.findWidgetByKey<SettingsTile>(SettingKeys.CONFIRM_DELETION);
      expect(confirmDeletionSwitch.initialValue, equals(false));

      // Verify the title and description are displayed correctly
      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(find.text('Show confirmation dialog before deleting items'),
          findsOneWidget);

      // Scroll to ensure the Confirm Deletion tile is visible
      await tester
          .ensureVisible(find.byKey(ValueKey(SettingKeys.CONFIRM_DELETION)));
      await tester.pumpAndSettle(); // Wait for scrolling to complete

      // Tap the Confirm Deletion switch to toggle it
      await tester.tap(find.byKey(ValueKey(SettingKeys.CONFIRM_DELETION)));
      await tester.pumpAndSettle(); // Wait for state to update

      // Since we've set up the stream to emit a state with confirmDeletion: true,
      // we should now see the updated switch value
      final updatedConfirmDeletionSwitch =
          tester.findWidgetByKey<SettingsTile>(SettingKeys.CONFIRM_DELETION);
      expect(updatedConfirmDeletionSwitch.initialValue, equals(true));
    },
  );
}
