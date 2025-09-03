import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/bloc/update/update_bloc.dart';
import '../../lib/models/update_models.dart' hide UpdateErrorType;
import '../../lib/repositories/update_repository.dart';
import '../../lib/utils/logger_util.dart';

class MockUpdateRepository extends Mock implements UpdateRepository {}

// Fake classes for fallback values
class FakeUpdatePreferences extends Fake implements UpdatePreferences {}

class FakeDownloadProgress extends Fake implements DownloadProgress {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeUpdatePreferences());
    registerFallbackValue(FakeDownloadProgress());

    // Setup logger only if not already initialized
    try {
      setupLogger();
    } catch (e) {
      // Logger already initialized, ignore
    }
  });

  group('UpdateBloc', () {
    late UpdateBloc updateBloc;
    late MockUpdateRepository mockRepository;

    setUp(() {
      mockRepository = MockUpdateRepository();
      // Always stub initialize first as it's called on bloc creation
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      // Stub dispose as it's called when bloc is closed
      when(() => mockRepository.dispose()).thenAnswer((_) async {});
      updateBloc = UpdateBloc(repository: mockRepository);
    });

    tearDown(() {
      updateBloc.close();
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
              .thenAnswer((_) async => false);
        },
        build: () => updateBloc,
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
                  isManual: any(named: 'isManual')))
              .thenAnswer((_) async => testVersionInfo);
          when(() => mockRepository.currentVersion).thenReturn('2.0.0');
          when(() => mockRepository.isVersionNewer(any(), any()))
              .thenReturn(false);
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

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateDownloading] when download starts successfully',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.getPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.isConnectedToWifi())
              .thenAnswer((_) async => true);
          when(() => mockRepository.validateDownloadUrl(any()))
              .thenAnswer((_) async => true);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(StartDownloadEvent(testVersionInfo)),
        expect: () => [
          isA<UpdateDownloading>(),
        ],
        verify: (_) {
          verify(() => mockRepository.getPreferences()).called(1);
          verify(() => mockRepository.isConnectedToWifi()).called(1);
          verify(() => mockRepository
              .validateDownloadUrl(testVersionInfo.downloadUrl)).called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when WiFi required but not connected',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.getPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.isConnectedToWifi())
              .thenAnswer((_) async => false);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(StartDownloadEvent(testVersionInfo)),
        expect: () => [
          const UpdateError(
            message: 'WiFi connection required for download',
            errorType: UpdateErrorType.networkError,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getPreferences()).called(1);
          verify(() => mockRepository.isConnectedToWifi()).called(1);
          verifyNever(() => mockRepository.validateDownloadUrl(any()));
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when download URL is invalid',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.getPreferences())
              .thenAnswer((_) async => testPreferences);
          when(() => mockRepository.isConnectedToWifi())
              .thenAnswer((_) async => true);
          when(() => mockRepository.validateDownloadUrl(any()))
              .thenAnswer((_) async => false);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(StartDownloadEvent(testVersionInfo)),
        expect: () => [
          isA<UpdateError>()
        ],
        verify: (_) {
          verify(() => mockRepository.getPreferences()).called(1);
          verify(() => mockRepository.isConnectedToWifi()).called(1);
          verify(() => mockRepository
              .validateDownloadUrl(testVersionInfo.downloadUrl)).called(1);
        },
      );

      blocTest<UpdateBloc, UpdateState>(
        'allows download when WiFi not required',
        setUp: () {
          final nonWifiPreferences =
              testPreferences.copyWith(wifiOnlyDownload: false);
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.getPreferences())
              .thenAnswer((_) async => nonWifiPreferences);
          when(() => mockRepository.validateDownloadUrl(any()))
              .thenAnswer((_) async => true);
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(StartDownloadEvent(testVersionInfo)),
        expect: () => [
          isA<UpdateDownloading>(),
        ],
        verify: (_) {
          verify(() => mockRepository.getPreferences()).called(1);
          verifyNever(() => mockRepository.isConnectedToWifi());
          verify(() => mockRepository.validateDownloadUrl(any())).called(1);
        },
      );
    });

    group('SkipVersionEvent', () {
      blocTest<UpdateBloc, UpdateState>(
        'updates state to mark version as skipped',
        setUp: () {
          updateBloc.emit(UpdateAvailable(
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.skipVersion(any()))
              .thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.skipVersion(any()))
              .thenThrow(Exception('Storage error'));
        },
        build: () => updateBloc,
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
        // Keep false as intended
        showNotifications: false,
        lastCheckTime: DateTime.now(),
        skippedVersions: [],
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateWithPreferences] when preferences are updated',
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.savePreferences(any()))
              .thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.savePreferences(any()))
              .thenThrow(Exception('Storage error'));
        },
        build: () => updateBloc,
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
        setUp: () {
          updateBloc.emit(UpdateDownloading(
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
        'emits [UpdateDownloaded] when download completes',
        setUp: () {
          updateBloc.emit(UpdateDownloading(
            versionInfo: testVersionInfo,
            progress: DownloadProgress(
              taskId: 'test',
              progress: 0.9,
              downloaded: 921600,
              total: 1024000,
              fileName: 'app-v2.0.0.apk',
              status: DownloadStatus.downloading,
            ),
            startTime: DateTime.now(),
          ));
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
        },
        build: () => updateBloc,
        act: (bloc) => bloc.add(DownloadProgressEvent(
          DownloadProgress(
            taskId: 'test',
            progress: 1.0,
            downloaded: 1024000,
            total: 1024000,
            fileName: 'app-v2.0.0.apk',
            status: DownloadStatus.completed,
          ),
        )),
        expect: () => [
          isA<UpdateDownloaded>(),
        ],
      );

      blocTest<UpdateBloc, UpdateState>(
        'emits [UpdateError] when download fails',
        setUp: () {
          updateBloc.emit(UpdateDownloading(
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
          when(() => mockRepository.shouldPerformDailyCheck())
              .thenAnswer((_) async => true);
          when(() => mockRepository.checkForUpdates(
              isManual: any(named: 'isManual'))).thenAnswer((_) async => null);
        },
        build: () => updateBloc,
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
        setUp: () {
          when(() => mockRepository.initialize()).thenAnswer((_) async {});
        },
        build: () => updateBloc,
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
        updateBloc.emit(UpdateAvailable(
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

        expect(updateBloc.shouldShowUpdateNotification(), isTrue);
      });

      test('shouldShowUpdateNotification returns false for skipped update', () {
        updateBloc.emit(UpdateAvailable(
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

        expect(updateBloc.shouldShowUpdateNotification(), isFalse);
      });

      test(
          'shouldShowUpdateNotification returns false for non-available states',
          () {
        updateBloc.emit(const UpdateInitial());
        expect(updateBloc.shouldShowUpdateNotification(), isFalse);

        updateBloc.emit(const UpdateChecking(isManual: false));
        expect(updateBloc.shouldShowUpdateNotification(), isFalse);

        updateBloc.emit(UpdateNotAvailable(lastChecked: DateTime.now()));
        expect(updateBloc.shouldShowUpdateNotification(), isFalse);
      });

      test('getPreferences delegates to repository', () async {
        final testPreferences = UpdatePreferences(
          autoCheckEnabled: true,
          autoDownload: false,
          wifiOnlyDownload: true,
          // Explicitly true for WiFi test
          showNotifications: true,
          lastCheckTime: DateTime.now(),
          skippedVersions: [],
        );

        when(() => mockRepository.getPreferences())
            .thenAnswer((_) async => testPreferences);

        final preferences = await updateBloc.getPreferences();
        expect(preferences, testPreferences);
        verify(() => mockRepository.getPreferences()).called(1);
      });
    });

    group('performDailyCheckIfNeeded', () {
      test('performs check when daily check is needed', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenAnswer((_) async => true);
        when(() => mockRepository.checkForUpdates(
            isManual: any(named: 'isManual'))).thenAnswer((_) async => null);

        await updateBloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
        // Verify that CheckForUpdatesEvent was added (indirectly through repository call)
      });

      test('skips check when daily check is not needed', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenAnswer((_) async => false);

        await updateBloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
        verifyNever(() =>
            mockRepository.checkForUpdates(isManual: any(named: 'isManual')));
      });

      test('handles errors gracefully', () async {
        when(() => mockRepository.shouldPerformDailyCheck())
            .thenThrow(Exception('Storage error'));

        // Should not throw
        await updateBloc.performDailyCheckIfNeeded();

        verify(() => mockRepository.shouldPerformDailyCheck()).called(1);
      });
    });
  });
}
