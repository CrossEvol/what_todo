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
  );
}

// can not track the trailing of SwitchTile
void main()async {
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
}
