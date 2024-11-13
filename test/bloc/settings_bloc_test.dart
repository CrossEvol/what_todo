import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/setting_type.dart';
import 'package:flutter_app/pages/settings/setting.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/fake-database.mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late MockSettingsDB settingsDB;
  late SettingsBloc settingsBloc;
  await setupSharedPreference();

  setUp(() {
    settingsDB = MockSettingsDB();
    settingsBloc = SettingsBloc(settingsDB);
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsBloc', () {
    test('initial state is correct', () {
      expect(settingsBloc.state.useCountBadges, false);
      expect(settingsBloc.state.enableImportExport, false);
      expect(settingsBloc.state.status, ResultStatus.none);
      expect(settingsBloc.state.environment, Environment.development);
      expect(settingsBloc.state.language, Language.english);
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits [useCountBadges: true] when LoadSettingsEvent is added with existing setting',
      build: () {
        when(settingsDB.findByName(SettingKeys.USE_COUNT_BADGES))
            .thenAnswer((_) async => Setting(
                  key: SettingKeys.USE_COUNT_BADGES,
                  value: 'true',
                  updatedAt: DateTime.now(),
                  type: SettingType.Bool,
                ));
        when(settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT))
            .thenAnswer((_) async => Setting(
                  key: SettingKeys.ENABLE_IMPORT_EXPORT,
                  value: 'false',
                  updatedAt: DateTime.now(),
                  type: SettingType.Bool,
                ));
        when(settingsDB.findByName(SettingKeys.Environment))
            .thenAnswer((_) async => Setting(
                  key: SettingKeys.Environment,
                  value: Environment.development.name,
                  updatedAt: DateTime.now(),
                  type: SettingType.Text,
                ));
        when(settingsDB.findByName(SettingKeys.LANGUAGE))
            .thenAnswer((_) async => Setting(
                  key: SettingKeys.LANGUAGE,
                  value: Language.english.name,
                  updatedAt: DateTime.now(),
                  type: SettingType.Text,
                ));
        return settingsBloc;
      },
      act: (bloc) => bloc.add(LoadSettingsEvent()),
      expect: () => [
        predicate<SettingsState>(
          (state) => 
              state.useCountBadges == true &&
              state.enableImportExport == false &&
              state.environment == Environment.development &&
              state.language == Language.english,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [enableImportExport: true] when ToggleEnableImportExport is added',
      build: () {
        when(settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT))
            .thenAnswer((_) async => Setting(
                  id: 1,
                  key: SettingKeys.ENABLE_IMPORT_EXPORT,
                  value: 'false',
                  updatedAt: DateTime.now(),
                  type: SettingType.Bool,
                ));
        when(settingsDB.updateSetting(any)).thenAnswer((_) async => true);
        return settingsBloc;
      },
      act: (bloc) => bloc.add(ToggleEnableImportExport()),
      expect: () => [
        predicate<SettingsState>(
          (state) =>
              state.enableImportExport == true &&
              state.status == ResultStatus.success &&
              state.updatedKey == SettingKeys.ENABLE_IMPORT_EXPORT,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [environment: Environment.production] when ToggleEnvironment is added',
      build: () {
        when(settingsDB.findByName(SettingKeys.Environment))
            .thenAnswer((_) async => Setting(
                  id: 1,
                  key: SettingKeys.Environment,
                  value: Environment.development.name,
                  updatedAt: DateTime.now(),
                  type: SettingType.Text,
                ));
        when(settingsDB.updateSetting(any)).thenAnswer((_) async => true);
        return settingsBloc;
      },
      act: (bloc) => bloc
          .add(const ToggleEnvironment(environment: Environment.production)),
      expect: () => [
        predicate<SettingsState>(
          (state) =>
              state.environment == Environment.production &&
              state.status == ResultStatus.success &&
              state.updatedKey == SettingKeys.Environment,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [language: Language.japanese] when ToggleLanguage is added',
      build: () {
        when(settingsDB.findByName(SettingKeys.LANGUAGE))
            .thenAnswer((_) async => Setting(
                  id: 1,
                  key: SettingKeys.LANGUAGE,
                  value: Language.english.name,
                  updatedAt: DateTime.now(),
                  type: SettingType.Text,
                ));
        when(settingsDB.updateSetting(any)).thenAnswer((_) async => true);
        return settingsBloc;
      },
      act: (bloc) =>
          bloc.add(const ToggleLanguage(language: Language.japanese)),
      expect: () => [
        predicate<SettingsState>(
          (state) =>
              state.language == Language.japanese &&
              state.status == ResultStatus.success &&
              state.updatedKey == SettingKeys.LANGUAGE,
        ),
      ],
    );
  });
}
