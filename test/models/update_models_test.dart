import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/update_models.dart';

void main() {
  group('VersionInfo', () {
    test('should create VersionInfo with all required fields', () {
      final publishedAt = DateTime.now();
      final versionInfo = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      expect(versionInfo.version, '1.0.0');
      expect(versionInfo.downloadUrl, 'https://example.com/app.apk');
      expect(versionInfo.releaseNotes, 'Initial release');
      expect(versionInfo.publishedAt, publishedAt);
      expect(versionInfo.fileSize, 1024000);
      expect(versionInfo.fileName, 'app-v1.0.0.apk');
    });

    test('should create VersionInfo with optional fields as null', () {
      final publishedAt = DateTime.now();
      final versionInfo = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: null,
        publishedAt: publishedAt,
        fileSize: null,
        fileName: 'app-v1.0.0.apk',
      );

      expect(versionInfo.releaseNotes, isNull);
      expect(versionInfo.fileSize, isNull);
    });

    test('should support equality comparison', () {
      final publishedAt = DateTime.now();
      final versionInfo1 = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      final versionInfo2 = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      expect(versionInfo1, equals(versionInfo2));
      expect(versionInfo1.hashCode, equals(versionInfo2.hashCode));
    });

    test('should not be equal when properties differ', () {
      final publishedAt = DateTime.now();
      final versionInfo1 = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      final versionInfo2 = VersionInfo(
        version: '2.0.0', // Different version
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      expect(versionInfo1, isNot(equals(versionInfo2)));
    });

    test('should convert to string for debugging', () {
      final publishedAt = DateTime.now();
      final versionInfo = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      final string = versionInfo.toString();
      expect(string, contains('VersionInfo'));
      expect(string, contains('1.0.0'));
      expect(string, contains('app-v1.0.0.apk'));
    });

    test('should create copy with modified properties', () {
      final publishedAt = DateTime.now();
      final originalVersionInfo = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      final copiedVersionInfo = originalVersionInfo.copyWith(
        version: '2.0.0',
        releaseNotes: 'Major update',
      );

      expect(copiedVersionInfo.version, '2.0.0');
      expect(copiedVersionInfo.releaseNotes, 'Major update');
      expect(copiedVersionInfo.downloadUrl, originalVersionInfo.downloadUrl);
      expect(copiedVersionInfo.publishedAt, originalVersionInfo.publishedAt);
      expect(copiedVersionInfo.fileSize, originalVersionInfo.fileSize);
      expect(copiedVersionInfo.fileName, originalVersionInfo.fileName);
    });

    test('should handle JSON serialization and deserialization', () {
      final publishedAt = DateTime.now();
      final versionInfo = VersionInfo(
        version: '1.0.0',
        downloadUrl: 'https://example.com/app.apk',
        releaseNotes: 'Initial release',
        publishedAt: publishedAt,
        fileSize: 1024000,
        fileName: 'app-v1.0.0.apk',
      );

      final json = versionInfo.toJson();
      final fromJson = VersionInfo.fromJson(json);

      expect(fromJson, equals(versionInfo));
    });

    test('should handle JSON with null values', () {
      final json = {
        'version': '1.0.0',
        'downloadUrl': 'https://example.com/app.apk',
        'releaseNotes': null,
        'publishedAt': DateTime.now().toIso8601String(),
        'fileSize': null,
        'fileName': 'app-v1.0.0.apk',
      };

      final versionInfo = VersionInfo.fromJson(json);

      expect(versionInfo.version, '1.0.0');
      expect(versionInfo.releaseNotes, isNull);
      expect(versionInfo.fileSize, isNull);
    });
  });

  group('DownloadProgress', () {
    test('should create DownloadProgress with all required fields', () {
      final progress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      expect(progress.taskId, 'task_123');
      expect(progress.progress, 0.5);
      expect(progress.downloaded, 512000);
      expect(progress.total, 1024000);
      expect(progress.fileName, 'app.apk');
      expect(progress.status, DownloadStatus.downloading);
      expect(progress.error, isNull);
    });

    test('should create DownloadProgress with error', () {
      final progress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.3,
        downloaded: 307200,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.failed,
        error: 'Network timeout',
      );

      expect(progress.error, 'Network timeout');
      expect(progress.status, DownloadStatus.failed);
    });

    test('should support equality comparison', () {
      final progress1 = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      final progress2 = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apv',
        status: DownloadStatus.downloading,
      );

      expect(progress1, equals(progress2));
    });

    test('should create copy with modified properties', () {
      final originalProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      final copiedProgress = originalProgress.copyWith(
        progress: 0.8,
        downloaded: 819200,
        status: DownloadStatus.downloading,
      );

      expect(copiedProgress.progress, 0.8);
      expect(copiedProgress.downloaded, 819200);
      expect(copiedProgress.taskId, originalProgress.taskId);
      expect(copiedProgress.total, originalProgress.total);
      expect(copiedProgress.fileName, originalProgress.fileName);
    });

    test('should calculate percentage correctly', () {
      final progress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.75,
        downloaded: 768000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      expect(progress.percentageComplete, 75.0);
    });

    test('should handle edge cases for percentage', () {
      // Zero progress
      final zeroProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.0,
        downloaded: 0,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.pending,
      );

      expect(zeroProgress.percentageComplete, 0.0);

      // Complete progress
      final completeProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 1.0,
        downloaded: 1024000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.completed,
      );

      expect(completeProgress.percentageComplete, 100.0);
    });

    test('should format download speed and ETA', () {
      final progress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
        speed: 102400, // 100 KB/s
        estimatedTimeRemaining: const Duration(seconds: 5),
      );

      expect(progress.formattedSpeed, '100.0 KB/s');
      expect(progress.formattedETA, '5 seconds remaining');
    });

    test('should check if download is complete', () {
      final incompleteProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      final completeProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 1.0,
        downloaded: 1024000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.completed,
      );

      expect(incompleteProgress.isComplete, isFalse);
      expect(completeProgress.isComplete, isTrue);
    });

    test('should check if download failed', () {
      final successProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.5,
        downloaded: 512000,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.downloading,
      );

      final failedProgress = DownloadProgress(
        taskId: 'task_123',
        progress: 0.3,
        downloaded: 307200,
        total: 1024000,
        fileName: 'app.apk',
        status: DownloadStatus.failed,
        error: 'Network error',
      );

      expect(successProgress.hasFailed, isFalse);
      expect(failedProgress.hasFailed, isTrue);
    });
  });

  group('UpdatePreferences', () {
    test('should create UpdatePreferences with default values', () {
      final preferences = UpdatePreferences();

      expect(preferences.autoCheckEnabled, isTrue);
      expect(preferences.autoDownload, isFalse);
      expect(preferences.wifiOnlyDownload, isTrue);
      expect(preferences.showNotifications, isTrue);
      expect(preferences.lastCheckTime, isNull);
      expect(preferences.skippedVersions, isEmpty);
    });

    test('should create UpdatePreferences with custom values', () {
      final lastCheck = DateTime.now();
      final skippedVersions = ['1.0.0', '1.1.0'];
      
      final preferences = UpdatePreferences(
        autoCheckEnabled: false,
        autoDownload: true,
        wifiOnlyDownload: false,
        showNotifications: false,
        lastCheckTime: lastCheck,
        skippedVersions: skippedVersions,
      );

      expect(preferences.autoCheckEnabled, isFalse);
      expect(preferences.autoDownload, isTrue);
      expect(preferences.wifiOnlyDownload, isFalse);
      expect(preferences.showNotifications, isFalse);
      expect(preferences.lastCheckTime, lastCheck);
      expect(preferences.skippedVersions, skippedVersions);
    });

    test('should support equality comparison', () {
      final lastCheck = DateTime.now();
      final preferences1 = UpdatePreferences(
        autoCheckEnabled: true,
        autoDownload: false,
        wifiOnlyDownload: true,
        showNotifications: true,
        lastCheckTime: lastCheck,
        skippedVersions: ['1.0.0'],
      );

      final preferences2 = UpdatePreferences(
        autoCheckEnabled: true,
        autoDownload: false,
        wifiOnlyDownload: true,
        showNotifications: true,
        lastCheckTime: lastCheck,
        skippedVersions: ['1.0.0'],
      );

      expect(preferences1, equals(preferences2));
      expect(preferences1.hashCode, equals(preferences2.hashCode));
    });

    test('should create copy with modified properties', () {
      final originalPreferences = UpdatePreferences(
        autoCheckEnabled: true,
        autoDownload: false,
        wifiOnlyDownload: true,
        showNotifications: true,
        lastCheckTime: DateTime.now(),
        skippedVersions: ['1.0.0'],
      );

      final copiedPreferences = originalPreferences.copyWith(
        autoCheckEnabled: false,
        skippedVersions: ['1.0.0', '1.1.0'],
      );

      expect(copiedPreferences.autoCheckEnabled, isFalse);
      expect(copiedPreferences.skippedVersions, ['1.0.0', '1.1.0']);
      expect(copiedPreferences.autoDownload, originalPreferences.autoDownload);
      expect(copiedPreferences.wifiOnlyDownload, originalPreferences.wifiOnlyDownload);
      expect(copiedPreferences.showNotifications, originalPreferences.showNotifications);
      expect(copiedPreferences.lastCheckTime, originalPreferences.lastCheckTime);
    });

    test('should handle JSON serialization and deserialization', () {
      final lastCheck = DateTime.now();
      final preferences = UpdatePreferences(
        autoCheckEnabled: false,
        autoDownload: true,
        wifiOnlyDownload: false,
        showNotifications: false,
        lastCheckTime: lastCheck,
        skippedVersions: ['1.0.0', '1.1.0'],
      );

      final json = preferences.toJson();
      final fromJson = UpdatePreferences.fromJson(json);

      expect(fromJson, equals(preferences));
    });

    test('should handle JSON with null lastCheckTime', () {
      final json = {
        'autoCheckEnabled': true,
        'autoDownload': false,
        'wifiOnlyDownload': true,
        'showNotifications': true,
        'lastCheckTime': null,
        'skippedVersions': <String>[],
      };

      final preferences = UpdatePreferences.fromJson(json);

      expect(preferences.autoCheckEnabled, isTrue);
      expect(preferences.lastCheckTime, isNull);
      expect(preferences.skippedVersions, isEmpty);
    });

    test('should check if version is skipped', () {
      final preferences = UpdatePreferences(
        skippedVersions: ['1.0.0', '1.1.0', '2.0.0-beta'],
      );

      expect(preferences.isVersionSkipped('1.0.0'), isTrue);
      expect(preferences.isVersionSkipped('1.1.0'), isTrue);
      expect(preferences.isVersionSkipped('2.0.0-beta'), isTrue);
      expect(preferences.isVersionSkipped('2.0.0'), isFalse);
      expect(preferences.isVersionSkipped('1.2.0'), isFalse);
    });

    test('should check if daily check is due', () {
      // Never checked before
      final neverChecked = UpdatePreferences(lastCheckTime: null);
      expect(neverChecked.isDailyCheckDue(), isTrue);

      // Checked recently (within 24 hours)
      final recentlyChecked = UpdatePreferences(
        lastCheckTime: DateTime.now().subtract(const Duration(hours: 12)),
      );
      expect(recentlyChecked.isDailyCheckDue(), isFalse);

      // Checked more than 24 hours ago
      final oldCheck = UpdatePreferences(
        lastCheckTime: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(oldCheck.isDailyCheckDue(), isTrue);

      // Exactly 24 hours ago (edge case)
      final exactlyOneDayAgo = UpdatePreferences(
        lastCheckTime: DateTime.now().subtract(const Duration(hours: 24)),
      );
      expect(exactlyOneDayAgo.isDailyCheckDue(), isTrue);
    });

    test('should add and remove skipped versions', () {
      final preferences = UpdatePreferences(
        skippedVersions: ['1.0.0'],
      );

      // Add new skipped version
      final withNewSkipped = preferences.addSkippedVersion('1.1.0');
      expect(withNewSkipped.skippedVersions, ['1.0.0', '1.1.0']);

      // Add duplicate skipped version (should not duplicate)
      final withDuplicate = withNewSkipped.addSkippedVersion('1.0.0');
      expect(withDuplicate.skippedVersions, ['1.0.0', '1.1.0']);

      // Remove skipped version
      final withRemoved = withNewSkipped.removeSkippedVersion('1.0.0');
      expect(withRemoved.skippedVersions, ['1.1.0']);

      // Remove non-existent version (should not affect list)
      final withNonExistent = withRemoved.removeSkippedVersion('2.0.0');
      expect(withNonExistent.skippedVersions, ['1.1.0']);

      // Clear all skipped versions
      final cleared = withNewSkipped.clearSkippedVersions();
      expect(cleared.skippedVersions, isEmpty);
    });
  });

  group('DownloadStatus', () {
    test('should have all expected status values', () {
      expect(DownloadStatus.values, contains(DownloadStatus.pending));
      expect(DownloadStatus.values, contains(DownloadStatus.downloading));
      expect(DownloadStatus.values, contains(DownloadStatus.paused));
      expect(DownloadStatus.values, contains(DownloadStatus.completed));
      expect(DownloadStatus.values, contains(DownloadStatus.failed));
      expect(DownloadStatus.values, contains(DownloadStatus.cancelled));
    });

    test('should provide user-friendly display names', () {
      expect(DownloadStatus.pending.displayName, 'Pending');
      expect(DownloadStatus.downloading.displayName, 'Downloading');
      expect(DownloadStatus.paused.displayName, 'Paused');
      expect(DownloadStatus.completed.displayName, 'Completed');
      expect(DownloadStatus.failed.displayName, 'Failed');
      expect(DownloadStatus.cancelled.displayName, 'Cancelled');
    });

    test('should identify terminal states', () {
      expect(DownloadStatus.pending.isTerminal, isFalse);
      expect(DownloadStatus.downloading.isTerminal, isFalse);
      expect(DownloadStatus.paused.isTerminal, isFalse);
      expect(DownloadStatus.completed.isTerminal, isTrue);
      expect(DownloadStatus.failed.isTerminal, isTrue);
      expect(DownloadStatus.cancelled.isTerminal, isTrue);
    });

    test('should identify active states', () {
      expect(DownloadStatus.pending.isActive, isTrue);
      expect(DownloadStatus.downloading.isActive, isTrue);
      expect(DownloadStatus.paused.isActive, isTrue);
      expect(DownloadStatus.completed.isActive, isFalse);
      expect(DownloadStatus.failed.isActive, isFalse);
      expect(DownloadStatus.cancelled.isActive, isFalse);
    });
  });

  group('UpdateErrorType', () {
    test('should have all expected error types', () {
      expect(UpdateErrorType.values, contains(UpdateErrorType.networkError));
      expect(UpdateErrorType.values, contains(UpdateErrorType.permissionDenied));
      expect(UpdateErrorType.values, contains(UpdateErrorType.downloadFailed));
      expect(UpdateErrorType.values, contains(UpdateErrorType.installationFailed));
      expect(UpdateErrorType.values, contains(UpdateErrorType.fileNotFound));
      expect(UpdateErrorType.values, contains(UpdateErrorType.invalidVersion));
      expect(UpdateErrorType.values, contains(UpdateErrorType.unknown));
    });

    test('should provide user-friendly display names', () {
      expect(UpdateErrorType.networkError.displayName, 'Network Error');
      expect(UpdateErrorType.permissionDenied.displayName, 'Permission Denied');
      expect(UpdateErrorType.downloadFailed.displayName, 'Download Failed');
      expect(UpdateErrorType.installationFailed.displayName, 'Installation Failed');
      expect(UpdateErrorType.fileNotFound.displayName, 'File Not Found');
      expect(UpdateErrorType.invalidVersion.displayName, 'Invalid Version');
      expect(UpdateErrorType.unknown.displayName, 'Unknown Error');
    });

    test('should provide appropriate error descriptions', () {
      expect(
        UpdateErrorType.networkError.description,
        contains('network'),
      );
      expect(
        UpdateErrorType.permissionDenied.description,
        contains('permission'),
      );
      expect(
        UpdateErrorType.downloadFailed.description,
        contains('download'),
      );
      expect(
        UpdateErrorType.installationFailed.description,
        contains('install'),
      );
      expect(
        UpdateErrorType.fileNotFound.description,
        contains('file'),
      );
    });

    test('should identify recoverable errors', () {
      expect(UpdateErrorType.networkError.isRecoverable, isTrue);
      expect(UpdateErrorType.downloadFailed.isRecoverable, isTrue);
      expect(UpdateErrorType.permissionDenied.isRecoverable, isTrue);
      expect(UpdateErrorType.fileNotFound.isRecoverable, isFalse);
      expect(UpdateErrorType.invalidVersion.isRecoverable, isFalse);
      expect(UpdateErrorType.installationFailed.isRecoverable, isFalse);
    });
  });
}