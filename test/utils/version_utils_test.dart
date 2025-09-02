import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/version_utils.dart';

void main() {
  group('VersionUtils', () {
    late VersionUtils versionUtils;

    setUp(() {
      versionUtils = VersionUtils.instance;
    });

    group('parseVersion', () {
      test('should parse valid semantic version', () {
        final version = versionUtils.parseVersion('1.2.3');
        expect(version, isNotNull);
        expect(version!.major, 1);
        expect(version.minor, 2);
        expect(version.patch, 3);
      });

      test('should parse version with v prefix', () {
        final version = versionUtils.parseVersion('v1.2.3');
        expect(version, isNotNull);
        expect(version!.major, 1);
        expect(version.minor, 2);
        expect(version.patch, 3);
      });

      test('should parse version with pre-release', () {
        final version = versionUtils.parseVersion('1.2.3-beta');
        expect(version, isNotNull);
        expect(version!.major, 1);
        expect(version.minor, 2);
        expect(version.patch, 3);
        expect(version.preRelease, isNotEmpty);
      });

      test('should handle invalid version strings', () {
        final version = versionUtils.parseVersion('invalid');
        expect(version, isNull);
      });

      test('should handle partial version strings', () {
        final version = versionUtils.parseVersion('1.2');
        expect(version, isNotNull);
        expect(version!.major, 1);
        expect(version.minor, 2);
        expect(version.patch, 0);
      });

      test('should handle single digit version', () {
        final version = versionUtils.parseVersion('1');
        expect(version, isNotNull);
        expect(version!.major, 1);
        expect(version.minor, 0);
        expect(version.patch, 0);
      });
    });

    group('compareVersions', () {
      test('should return newer when first version is newer', () {
        final result = versionUtils.compareVersions('2.0.0', '1.0.0');
        expect(result, VersionComparisonResult.newer);
      });

      test('should return older when first version is older', () {
        final result = versionUtils.compareVersions('1.0.0', '2.0.0');
        expect(result, VersionComparisonResult.older);
      });

      test('should return same when versions are equal', () {
        final result = versionUtils.compareVersions('1.0.0', '1.0.0');
        expect(result, VersionComparisonResult.same);
      });

      test('should handle v prefix in comparison', () {
        final result = versionUtils.compareVersions('v2.0.0', '1.0.0');
        expect(result, VersionComparisonResult.newer);
      });

      test('should return invalid for malformed versions', () {
        final result = versionUtils.compareVersions('invalid', '1.0.0');
        expect(result, VersionComparisonResult.invalid);
      });

      test('should compare pre-release versions correctly', () {
        final result = versionUtils.compareVersions('1.0.0-beta', '1.0.0-alpha');
        expect(result, VersionComparisonResult.newer);
      });

      test('should treat stable as newer than pre-release', () {
        final result = versionUtils.compareVersions('1.0.0', '1.0.0-beta');
        expect(result, VersionComparisonResult.newer);
      });
    });

    group('isNewerVersion', () {
      test('should return true for newer version', () {
        final result = versionUtils.isNewerVersion('1.0.0', '2.0.0');
        expect(result, isTrue);
      });

      test('should return false for older version', () {
        final result = versionUtils.isNewerVersion('2.0.0', '1.0.0');
        expect(result, isFalse);
      });

      test('should return false for same version', () {
        final result = versionUtils.isNewerVersion('1.0.0', '1.0.0');
        expect(result, isFalse);
      });

      test('should handle patch version differences', () {
        final result = versionUtils.isNewerVersion('1.0.0', '1.0.1');
        expect(result, isTrue);
      });

      test('should handle minor version differences', () {
        final result = versionUtils.isNewerVersion('1.0.0', '1.1.0');
        expect(result, isTrue);
      });

      test('should handle major version differences', () {
        final result = versionUtils.isNewerVersion('1.0.0', '2.0.0');
        expect(result, isTrue);
      });
    });

    group('getUpgradeType', () {
      test('should return major for major version upgrade', () {
        final result = versionUtils.getUpgradeType('1.0.0', '2.0.0');
        expect(result, VersionUpgradeType.major);
      });

      test('should return minor for minor version upgrade', () {
        final result = versionUtils.getUpgradeType('1.0.0', '1.1.0');
        expect(result, VersionUpgradeType.minor);
      });

      test('should return patch for patch version upgrade', () {
        final result = versionUtils.getUpgradeType('1.0.0', '1.0.1');
        expect(result, VersionUpgradeType.patch);
      });

      test('should return none for same version', () {
        final result = versionUtils.getUpgradeType('1.0.0', '1.0.0');
        expect(result, VersionUpgradeType.none);
      });

      test('should return unknown for invalid versions', () {
        final result = versionUtils.getUpgradeType('invalid', '1.0.0');
        expect(result, VersionUpgradeType.unknown);
      });

      test('should prioritize major over minor changes', () {
        final result = versionUtils.getUpgradeType('1.0.0', '2.1.1');
        expect(result, VersionUpgradeType.major);
      });

      test('should prioritize minor over patch changes', () {
        final result = versionUtils.getUpgradeType('1.0.0', '1.1.1');
        expect(result, VersionUpgradeType.minor);
      });
    });

    group('sortVersions', () {
      test('should sort versions in ascending order', () {
        final versions = ['2.0.0', '1.0.0', '1.1.0'];
        final sorted = versionUtils.sortVersions(versions);
        expect(sorted, ['1.0.0', '1.1.0', '2.0.0']);
      });

      test('should handle v prefixes in sorting', () {
        final versions = ['v2.0.0', 'v1.0.0', 'v1.1.0'];
        final sorted = versionUtils.sortVersions(versions);
        expect(sorted, ['v1.0.0', 'v1.1.0', 'v2.0.0']);
      });

      test('should handle pre-release versions', () {
        final versions = ['1.0.0', '1.0.0-beta', '1.0.0-alpha'];
        final sorted = versionUtils.sortVersions(versions);
        expect(sorted.first, '1.0.0-alpha');
        expect(sorted.last, '1.0.0');
      });

      test('should return original list for invalid versions', () {
        final versions = ['invalid', 'also-invalid'];
        final sorted = versionUtils.sortVersions(versions);
        expect(sorted, versions);
      });
    });

    group('getLatestVersion', () {
      test('should return latest version from list', () {
        final versions = ['1.0.0', '2.0.0', '1.1.0'];
        final latest = versionUtils.getLatestVersion(versions);
        expect(latest, '2.0.0');
      });

      test('should return null for empty list', () {
        final latest = versionUtils.getLatestVersion([]);
        expect(latest, isNull);
      });

      test('should handle single version', () {
        final latest = versionUtils.getLatestVersion(['1.0.0']);
        expect(latest, '1.0.0');
      });
    });

    group('getVersionComponents', () {
      test('should extract version components correctly', () {
        final components = versionUtils.getVersionComponents('1.2.3');
        expect(components, isNotNull);
        expect(components!.major, 1);
        expect(components.minor, 2);
        expect(components.patch, 3);
        expect(components.preRelease, isNull);
        expect(components.build, isNull);
      });

      test('should extract pre-release information', () {
        final components = versionUtils.getVersionComponents('1.2.3-beta.1');
        expect(components, isNotNull);
        expect(components!.preRelease, 'beta.1');
        expect(components.isPreRelease, isTrue);
        expect(components.isStable, isFalse);
      });

      test('should handle build metadata', () {
        final components = versionUtils.getVersionComponents('1.2.3+build.1');
        expect(components, isNotNull);
        expect(components!.build, 'build.1');
      });

      test('should return null for invalid version', () {
        final components = versionUtils.getVersionComponents('invalid');
        expect(components, isNull);
      });

      test('should provide display strings', () {
        final components = versionUtils.getVersionComponents('1.2.3-beta');
        expect(components, isNotNull);
        expect(components!.shortDisplay, '1.2.3');
        expect(components.fullDisplay, '1.2.3-beta');
      });
    });

    group('formatVersionForDisplay', () {
      test('should format version with prefix by default', () {
        final formatted = versionUtils.formatVersionForDisplay('1.2.3');
        expect(formatted, 'v1.2.3');
      });

      test('should format version without prefix when requested', () {
        final formatted = versionUtils.formatVersionForDisplay('1.2.3', includePrefix: false);
        expect(formatted, '1.2.3');
      });

      test('should handle pre-release in formatting', () {
        final formatted = versionUtils.formatVersionForDisplay('1.2.3-beta');
        expect(formatted, 'v1.2.3-beta');
      });

      test('should return original for invalid version', () {
        final formatted = versionUtils.formatVersionForDisplay('invalid');
        expect(formatted, 'invalid');
      });
    });

    group('isValidGitHubReleaseTag', () {
      test('should validate standard GitHub release tags', () {
        expect(versionUtils.isValidGitHubReleaseTag('v1.0.0'), isTrue);
        expect(versionUtils.isValidGitHubReleaseTag('1.0.0'), isTrue);
        expect(versionUtils.isValidGitHubReleaseTag('v1.0.0-beta'), isTrue);
        expect(versionUtils.isValidGitHubReleaseTag('v1.0.0-beta.1'), isTrue);
      });

      test('should reject invalid GitHub release tags', () {
        expect(versionUtils.isValidGitHubReleaseTag('invalid'), isFalse);
        expect(versionUtils.isValidGitHubReleaseTag('v1.0'), isFalse);
        expect(versionUtils.isValidGitHubReleaseTag('1.0'), isFalse);
      });
    });

    group('extractVersionFromReleaseName', () {
      test('should extract version from release names', () {
        expect(versionUtils.extractVersionFromReleaseName('Release v1.0.0'), '1.0.0');
        expect(versionUtils.extractVersionFromReleaseName('v2.1.3'), '2.1.3');
        expect(versionUtils.extractVersionFromReleaseName('Version 1.5.0-beta'), '1.5.0-beta');
      });

      test('should return null for names without versions', () {
        expect(versionUtils.extractVersionFromReleaseName('No version here'), isNull);
        expect(versionUtils.extractVersionFromReleaseName(''), isNull);
      });
    });

    group('getVersionDifference', () {
      test('should describe upgrade types correctly', () {
        expect(
          versionUtils.getVersionDifference('1.0.0', '2.0.0'),
          contains('Major update'),
        );
        expect(
          versionUtils.getVersionDifference('1.0.0', '1.1.0'),
          contains('Minor update'),
        );
        expect(
          versionUtils.getVersionDifference('1.0.0', '1.0.1'),
          contains('Patch update'),
        );
        expect(
          versionUtils.getVersionDifference('1.0.0', '1.0.0'),
          contains('No version change'),
        );
      });
    });

    group('satisfiesConstraint', () {
      test('should check version constraints correctly', () {
        expect(versionUtils.satisfiesConstraint('1.5.0', '^1.0.0'), isTrue);
        expect(versionUtils.satisfiesConstraint('2.0.0', '^1.0.0'), isFalse);
        expect(versionUtils.satisfiesConstraint('1.0.5', '~1.0.0'), isTrue);
        expect(versionUtils.satisfiesConstraint('1.1.0', '~1.0.0'), isFalse);
      });

      test('should handle invalid versions in constraints', () {
        expect(versionUtils.satisfiesConstraint('invalid', '^1.0.0'), isFalse);
      });
    });

    group('getNextVersions', () {
      test('should calculate next versions correctly', () {
        final nextVersions = versionUtils.getNextVersions('1.2.3');
        expect(nextVersions[VersionUpgradeType.patch], '1.2.4');
        expect(nextVersions[VersionUpgradeType.minor], '1.3.0');
        expect(nextVersions[VersionUpgradeType.major], '2.0.0');
      });

      test('should return empty map for invalid version', () {
        final nextVersions = versionUtils.getNextVersions('invalid');
        expect(nextVersions, isEmpty);
      });
    });
  });

  group('VersionStringExtensions', () {
    test('should provide convenient extension methods', () {
      expect('1.0.0'.isValidVersion, isTrue);
      expect('invalid'.isValidVersion, isFalse);
      expect('2.0.0'.isNewerThan('1.0.0'), isTrue);
      expect('1.0.0'.isOlderThan('2.0.0'), isTrue);
    });

    test('should format versions using extensions', () {
      expect('1.0.0'.formatForDisplay(), 'v1.0.0');
      expect('1.0.0'.formatForDisplay(includePrefix: false), '1.0.0');
    });

    test('should get version components using extensions', () {
      final components = '1.2.3'.versionComponents;
      expect(components, isNotNull);
      expect(components!.major, 1);
      expect(components.minor, 2);
      expect(components.patch, 3);
    });
  });
}