import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/bloc/update/update_bloc.dart';
import '../../lib/models/update_models.dart' hide UpdateErrorType;
import '../../lib/repositories/update_repository.dart';
import '../../lib/utils/download_manager.dart';
import '../../lib/utils/file_manager.dart';
import '../../lib/utils/logger_util.dart';

// Mocks
class MockUpdateRepository extends Mock implements UpdateRepository {}

class MockDownloadManager extends Mock implements DownloadManager {}

class MockFileManager extends Mock implements FileManager {}

// Fake classes for fallback values
class FakeUpdatePreferences extends Fake implements UpdatePreferences {}

class FakeDownloadProgress extends Fake implements DownloadProgress {}

class FakeVersionInfo extends Fake implements VersionInfo {}

void main() {
  // Global mock variables that will be used across all test groups
  late MockUpdateRepository mockRepository;
  late MockDownloadManager mockDownloadManager;
  late MockFileManager mockFileManager;
  late StreamController<DownloadProgress> downloadProgressController;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Register fallback values for mocktail
    registerFallbackValue(FakeUpdatePreferences());
    registerFallbackValue(FakeDownloadProgress());
    registerFallbackValue(FakeVersionInfo());

    // Setup logger only if not already initialized
    try {
      setupLogger();
    } catch (e) {
      // Logger already initialized, ignore
    }
  });

  setUp(() {
    // Initialize fresh mocks for each test
    mockRepository = MockUpdateRepository();
    mockDownloadManager = MockDownloadManager();
    mockFileManager = MockFileManager();
    downloadProgressController = StreamController<DownloadProgress>.broadcast();

    // Default stubs for all mocks
    when(() => mockRepository.initialize()).thenAnswer((_) async {});
    when(() => mockDownloadManager.initialize()).thenAnswer((_) async {});
    when(() => mockDownloadManager.progressStream)
        .thenAnswer((_) => downloadProgressController.stream);
    when(() => mockRepository.dispose()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await downloadProgressController.close();
  });

  group('UpdateBloc', () {
    late UpdateBloc updateBloc;

    setUp(() {
      updateBloc = UpdateBloc(
        repository: mockRepository,
        downloadManager: mockDownloadManager,
        fileManager: mockFileManager,
      );
    });

    tearDown(() async {
      await updateBloc.close();
    });

    test('initial state is UpdateInitial', () {
      expect(updateBloc.state, const UpdateInitial());
    });

    group('CheckForUpdatesEvent', () {
      final testVersionInfo = VersionInfo(
        version: '2.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'New features',
        publishedAt: DateTime.now(),
        fileSize: 1024000,
        fileName: 'app-v2.0.0.apk',
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateChecking, UpdateAvailable] when update is available',
        setUp: () {
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
                  isManual: any(named: 'isManual')))
              .thenAnswer((_) async => testVersionInfo);
          when(() => mockRepository.currentVersion).thenReturn('1.0.0');
          when(() => mockRepository.isVersionNewer(any(), any()))
              .thenReturn(true);
          when(() => mockRepository.isVersionSkipped(any()))
              .thenAnswer((_) async => false);
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: true)),
        expect: () => [
          const UpdateChecking(isManual: true),
          UpdateAvailable(
            versionInfo: testVersionInfo,
            currentVersion: '1.0.0',
            isSkipped: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.checkForUpdates(isManual: true))
              .called(1);
          verify(() => mockRepository.isVersionNewer('2.0.0', '1.0.0'))
              .called(1);
          verify(() => mockRepository.isVersionSkipped('2.0.0')).called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateChecking, UpdateNotAvailable] when no newer version',
        setUp: () {
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
                  isManual: any(named: 'isManual')))
              .thenAnswer((_) async => testVersionInfo);
          when(() => mockRepository.currentVersion).thenReturn('2.0.0');
          when(() => mockRepository.isVersionNewer(any(), any()))
              .thenReturn(false);
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: true)),
        expect: () => [
          const UpdateChecking(isManual: true),
          isA<UpdateNotAvailable>(),
        ],
        verify: (_) {
          verify(() => mockRepository.checkForUpdates(isManual: true))
              .called(1);
          verify(() => mockRepository.isVersionNewer('2.0.0', '2.0.0'))
              .called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateChecking, UpdateNotAvailable] when daily check not needed',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => false);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: false)),
        expect: () => [
          const UpdateChecking(isManual: false),
          isA<UpdateNotAvailable>(),
        ],
        verify: (_) {
          verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
          verifyNever(() =>
              mockRepository.checkForUpdates(isManual: any(named: 'isManual')));
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateChecking, UpdateError] when repository throws exception',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
                  isManual: any(named: 'isManual')))
              .thenThrow(Exception('Network error'));
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: true)),
        expect: () => [
          const UpdateChecking(isManual: true),
          isA<UpdateError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.checkForUpdates(isManual: true))
              .called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateChecking, UpdateNotAvailable] when version info is null',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
              isManual: any(named: 'isManual'))).thenAnswer((_) async => null);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: true)),
        expect: () => [
          const UpdateChecking(isManual: true),
          isA<UpdateNotAvailable>(),
        ],
        verify: (_) {
          verify(() => mockRepository.checkForUpdates(isManual: true))
              .called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'marks version as skipped when already skipped',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
                  isManual: any(named: 'isManual')))
              .thenAnswer((_) async => testVersionInfo);
          when(() => mockRepository.currentVersion).thenReturn('1.0.0');
          when(() => mockRepository.isVersionNewer(any(), any()))
              .thenReturn(true);
          when(() => mockRepository.isVersionSkipped(any()))
              .thenAnswer((_) async => true);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(const CheckForUpdatesEvent(isManual: true)),
        expect: () => [
          const UpdateChecking(isManual: true),
          UpdateAvailable(
            versionInfo: testVersionInfo,
            currentVersion: '1.0.0',
            isSkipped: true,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.isVersionSkipped('2.0.0')).called(1);
        },
      );
    });

    group('StartDownloadEvent', () {
      final testVersionInfo = VersionInfo(
        version: '2.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'New features',
        publishedAt: DateTime.now(),
        fileSize: 1024000,
        fileName: 'app-v2.0.0.apk',
      );

      final testPreferences = UpdatePreferences(
        autoCheckEnabled: true,
        autoDownload: false,
        wifiOnlyDownload: true,
        // Explicitly set to true for this test
        showNotifications: true,
        lastCheckTime: DateTime.now(),
        skippedVersions: [],
      );

    });

    group('SkipVersionEvent', () {
      blocTest<UpdateBloc, UpdateState>(
        'updates state to mark version as skipped',
        setUp: () {
          when(() => mockRepository.skipVersion(any()))
              .thenAnswer((_) async {});
        },
        build: () {
          final bloc = UpdateBloc(
            repository: mockRepository,
            downloadManager: mockDownloadManager,
            fileManager: mockFileManager,
          );
          bloc.emit(UpdateAvailable(
            versionInfo: VersionInfo(
              version: '2.0.0',
              downloadUrl: 'https://example.com/app.apk',
              releaseNotes: 'New features',
              publishedAt: DateTime.now(),
              fileSize: 1024000,
              fileName: 'app-v2.0.0.apk',
            ),
            currentVersion: '1.0.0',
            isSkipped: false,
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(const SkipVersionEvent('2.0.0')),
        expect: () => [
          isA<UpdateAvailable>()
              .having((state) => state.isSkipped, 'isSkipped', true),
        ],
        verify: (_) {
          verify(() => mockRepository.skipVersion('2.0.0')).called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when skip version fails',
        setUp: () {
          when(() => mockRepository.skipVersion(any()))
              .thenThrow(Exception('Storage error'));
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const SkipVersionEvent('2.0.0')),
        expect: () => [
          isA<UpdateError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.skipVersion('2.0.0')).called(1);
        },
      );
    });

    group('UpdatePreferencesEvent', () {
      final testPreferences = UpdatePreferences(
        autoCheckEnabled: false,
        autoDownload: true,
        wifiOnlyDownload: false,
        showNotifications: false,
        lastCheckTime: DateTime.now(),
        skippedVersions: [],
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateWithPreferences] when preferences are updated',
        setUp: () {
          when(() => mockRepository.savePreferences(any()))
              .thenAnswer((_) async {});
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(UpdatePreferencesEvent(testPreferences)),
        expect: () => [
          UpdateWithPreferences(
            currentState: const UpdateInitial(),
            preferences: testPreferences,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.savePreferences(testPreferences))
              .called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when saving preferences fails',
        setUp: () {
          when(() => mockRepository.savePreferences(any()))
              .thenThrow(Exception('Storage error'));
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(UpdatePreferencesEvent(testPreferences)),
        expect: () => [
          isA<UpdateError>(),
        ],
        verify: (_) {
          verify(() => mockRepository.savePreferences(testPreferences))
              .called(1);
        },
      );
    });

    group('DownloadProgressEvent', () {
      final testVersionInfo = VersionInfo(
        version: '2.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'New features',
        publishedAt: DateTime.now(),
        fileSize: 1024000,
        fileName: 'app-v2.0.0.apk',
      );

      blocTest<UpdateBloc, UpdateState>(
        'updates download progress when downloading',
        setUp: () {},
        build: () {
          final bloc = UpdateBloc(
            repository: mockRepository,
            downloadManager: mockDownloadManager,
            fileManager: mockFileManager,
          );
          bloc.emit(UpdateDownloading(
            versionInfo: testVersionInfo,
            progress: DownloadProgress(
              taskId: 'test',
              progress: 0.0,
              downloaded: 0,
              total: 1024000,
              fileName: 'app-v2.0.0.apk',
              status: DownloadStatus.downloading,
            ),
            startTime: DateTime.now(),
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(DownloadProgressEvent(
          DownloadProgress(
            taskId: 'test',
            progress: 0.5,
            downloaded: 512000,
            total: 1024000,
            fileName: 'app-v2.0.0.apk',
            status: DownloadStatus.downloading,
          ),
        )),
        expect: () => [
          isA<UpdateDownloading>().having(
            (state) => state.progress.progress,
            'progress',
            0.5,
          ),
        ],
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when download fails',
        setUp: () {},
        build: () {
          final bloc = UpdateBloc(
            repository: mockRepository,
            downloadManager: mockDownloadManager,
            fileManager: mockFileManager,
          );
          bloc.emit(UpdateDownloading(
            versionInfo: testVersionInfo,
            progress: DownloadProgress(
              taskId: 'test',
              progress: 0.3,
              downloaded: 307200,
              total: 1024000,
              fileName: 'app-v2.0.0.apk',
              status: DownloadStatus.downloading,
            ),
            startTime: DateTime.now(),
          ));
          return bloc;
        },
        act: (bloc) => bloc.add(DownloadProgressEvent(
          DownloadProgress(
            taskId: 'test',
            progress: 0.3,
            downloaded: 307200,
            total: 1024000,
            fileName: 'app-v2.0.0.apk',
            status: DownloadStatus.failed,
            error: 'Network connection lost',
          ),
        )),
        expect: () => [
          const UpdateError(
            message: 'Network connection lost',
            errorType: UpdateErrorType.downloadFailed,
          ),
        ],
      );
    });

    group('DismissUpdateEvent', () {
      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateInitial] when update is dismissed',
        setUp: () {},
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const DismissUpdateEvent()),
        expect: () => [
          const UpdateInitial(),
        ],
      );
    });

    group('RetryUpdateEvent', () {
      blocTest<UpdateBloc, UpdateState>(
        'triggers check for updates when retrying',
        setUp: () {
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
              isManual: any(named: 'isManual'))).thenAnswer((_) async => null);
        },
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const RetryUpdateEvent()),
        expect: () => [
          const UpdateChecking(isManual: true),
          isA<UpdateNotAvailable>(),
        ],
        verify: (_) {
          verify(() => mockRepository.checkForUpdates(isManual: true))
              .called(1);
        },
      );
    });

    group('ClearUpdateStateEvent', () {
      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateInitial] when state is cleared',
        setUp: () {},
        build: () => UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        ),
        act: (bloc) => bloc.add(const ClearUpdateStateEvent()),
        expect: () => [
          const UpdateInitial(),
        ],
      );
    });

    group('Helper methods', () {
      test(
          'shouldShowUpdateNotification returns true for available non-skipped update',
          () {
        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );
        bloc.emit(UpdateAvailable(
          versionInfo: VersionInfo(
            version: '2.0.0',
            downloadUrl: 'https://example.com/app.apk',
            releaseNotes: 'New features',
            publishedAt: DateTime.now(),
            fileSize: 1024000,
            fileName: 'app-v2.0.0.apk',
          ),
          currentVersion: '1.0.0',
          isSkipped: false,
        ));

        expect(bloc.shouldShowUpdateNotification(), isTrue);
        bloc.close();
      });

      test('shouldShowUpdateNotification returns false for skipped update', () {
        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );
        bloc.emit(UpdateAvailable(
          versionInfo: VersionInfo(
            version: '2.0.0',
            downloadUrl: 'https://example.com/app.apk',
            releaseNotes: 'New features',
            publishedAt: DateTime.now(),
            fileSize: 1024000,
            fileName: 'app-v2.0.0.apk',
          ),
          currentVersion: '1.0.0',
          isSkipped: true,
        ));

        expect(bloc.shouldShowUpdateNotification(), isFalse);
        bloc.close();
      });

      test(
          'shouldShowUpdateNotification returns false for non-available states',
          () {
        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );

        bloc.emit(const UpdateInitial());
        expect(bloc.shouldShowUpdateNotification(), isFalse);

        bloc.emit(const UpdateChecking(isManual: false));
        expect(bloc.shouldShowUpdateNotification(), isFalse);

        bloc.emit(UpdateNotAvailable(lastChecked: DateTime.now()));
        expect(bloc.shouldShowUpdateNotification(), isFalse);

        bloc.close();
      });

      test('getPreferences delegates to repository', () async {
        final testPreferences = UpdatePreferences(
          autoCheckEnabled: true,
          autoDownload: false,
          wifiOnlyDownload: true,
          showNotifications: true,
          lastCheckTime: DateTime.now(),
          skippedVersions: [],
        );

        when(() => mockRepository.getPreferences())
            .thenAnswer((_) async => testPreferences);

        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );

        final preferences = await bloc.getPreferences();
        expect(preferences, testPreferences);
        verify(() => mockRepository.getPreferences()).called(1);

        await bloc.close();
      });
    });

    group('performDailyCheckIfNeeded', () {
      test('performs check when daily check is needed', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenAnswer((_) async => true);
        when(() => mockRepository.checkForUpdates(
            isManual: any(named: 'isManual'))).thenAnswer((_) async => null);

        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );

        await bloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
        await bloc.close();
      });

      test('skips check when daily check is not needed', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenAnswer((_) async => false);

        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );

        await bloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
        verifyNever(() =>
            mockRepository.checkForUpdates(isManual: any(named: 'isManual')));
        await bloc.close();
      });

      test('handles errors gracefully', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenThrow(Exception('Storage error'));

        final bloc = UpdateBloc(
          repository: mockRepository,
          downloadManager: mockDownloadManager,
          fileManager: mockFileManager,
        );

        // Should not throw
        await bloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
        await bloc.close();
      });
    });
  });
}
