import 'package:pub_semver/pub_semver.dart';
import '../utils/logger_util.dart';

/// Utility class for version comparison and validation
class VersionUtils {
  static VersionUtils? _instance;
  static VersionUtils get instance {
    _instance ??= VersionUtils._internal();
    return _instance!;
  }

  VersionUtils._internal();

  /// Parse version string into Version object
  Version? parseVersion(String versionString) {
    try {
      // Clean the version string
      String cleanVersion = _cleanVersionString(versionString);
      return Version.parse(cleanVersion);
    } catch (e) {
      logger.error('Failed to parse version: $versionString - $e');
      return null;
    }
  }

  /// Clean version string (remove 'v' prefix, handle edge cases)
  String _cleanVersionString(String version) {
    String cleaned = version.trim();
    
    // Remove 'v' or 'V' prefix
    if (cleaned.toLowerCase().startsWith('v')) {
      cleaned = cleaned.substring(1);
    }
    
    // Handle semantic version parts
    final parts = cleaned.split('.');
    
    // Ensure we have at least major.minor.patch
    while (parts.length < 3) {
      parts.add('0');
    }
    
    // Take only first 3 parts for basic semantic versioning
    final semanticParts = parts.take(3).toList();
    
    // Validate each part is numeric
    for (int i = 0; i < semanticParts.length; i++) {
      final part = semanticParts[i];
      if (int.tryParse(part) == null) {
        // Try to extract numeric part
        final numericPart = RegExp(r'\d+').firstMatch(part)?.group(0);
        if (numericPart != null) {
          semanticParts[i] = numericPart;
        } else {
          semanticParts[i] = '0';
        }
      }
    }
    
    return semanticParts.join('.');
  }

  /// Compare two version strings
  VersionComparisonResult compareVersions(String version1, String version2) {
    try {
      final v1 = parseVersion(version1);
      final v2 = parseVersion(version2);
      
      if (v1 == null || v2 == null) {
        logger.warn('Failed to parse versions for comparison: $version1 vs $version2');
        return VersionComparisonResult.invalid;
      }
      
      if (v1 > v2) {
        return VersionComparisonResult.newer;
      } else if (v1 < v2) {
        return VersionComparisonResult.older;
      } else {
        return VersionComparisonResult.same;
      }
    } catch (e) {
      logger.error('Error comparing versions: $version1 vs $version2 - $e');
      return VersionComparisonResult.invalid;
    }
  }

  /// Check if new version is available
  bool isNewerVersion(String currentVersion, String newVersion) {
    final result = compareVersions(newVersion, currentVersion);
    return result == VersionComparisonResult.newer;
  }

  /// Check if version is valid semantic version
  bool isValidSemanticVersion(String version) {
    final parsed = parseVersion(version);
    return parsed != null;
  }

  /// Get version components
  VersionComponents? getVersionComponents(String version) {
    try {
      final parsed = parseVersion(version);
      if (parsed == null) return null;
      
      return VersionComponents(
        major: parsed.major,
        minor: parsed.minor,
        patch: parsed.patch,
        preRelease: parsed.preRelease.isNotEmpty ? parsed.preRelease.join('.') : null,
        build: parsed.build.isNotEmpty ? parsed.build.join('.') : null,
        originalString: version,
        cleanString: parsed.toString(),
      );
    } catch (e) {
      logger.error('Failed to get version components: $version - $e');
      return null;
    }
  }

  /// Format version for display
  String formatVersionForDisplay(String version, {bool includePrefix = true}) {
    try {
      final components = getVersionComponents(version);
      if (components == null) return version;
      
      String formatted = '${components.major}.${components.minor}.${components.patch}';
      
      if (components.preRelease != null) {
        formatted += '-${components.preRelease}';
      }
      
      if (includePrefix) {
        formatted = 'v$formatted';
      }
      
      return formatted;
    } catch (e) {
      logger.error('Failed to format version: $version - $e');
      return version;
    }
  }

  /// Get version upgrade type
  VersionUpgradeType getUpgradeType(String currentVersion, String newVersion) {
    try {
      final current = parseVersion(currentVersion);
      final newVer = parseVersion(newVersion);
      
      if (current == null || newVer == null) {
        return VersionUpgradeType.unknown;
      }
      
      if (newVer.major > current.major) {
        return VersionUpgradeType.major;
      } else if (newVer.minor > current.minor) {
        return VersionUpgradeType.minor;
      } else if (newVer.patch > current.patch) {
        return VersionUpgradeType.patch;
      } else {
        return VersionUpgradeType.none;
      }
    } catch (e) {
      logger.error('Failed to determine upgrade type: $currentVersion -> $newVersion - $e');
      return VersionUpgradeType.unknown;
    }
  }

  /// Get version difference description
  String getVersionDifference(String currentVersion, String newVersion) {
    final upgradeType = getUpgradeType(currentVersion, newVersion);
    
    switch (upgradeType) {
      case VersionUpgradeType.major:
        return 'Major update with potential breaking changes';
      case VersionUpgradeType.minor:
        return 'Minor update with new features';
      case VersionUpgradeType.patch:
        return 'Patch update with bug fixes';
      case VersionUpgradeType.none:
        return 'No version change';
      case VersionUpgradeType.unknown:
        return 'Version difference could not be determined';
    }
  }

  /// Sort versions in ascending order
  List<String> sortVersions(List<String> versions) {
    try {
      final versionsWithParsed = versions
          .map((v) => {'original': v, 'parsed': parseVersion(v)})
          .where((item) => item['parsed'] != null)
          .toList();
      
      versionsWithParsed.sort((a, b) {
        final versionA = a['parsed'] as Version;
        final versionB = b['parsed'] as Version;
        return versionA.compareTo(versionB);
      });
      
      return versionsWithParsed
          .map((item) => item['original'] as String)
          .toList();
    } catch (e) {
      logger.error('Failed to sort versions: $e');
      return versions; // Return original list on error
    }
  }

  /// Get latest version from a list
  String? getLatestVersion(List<String> versions) {
    try {
      if (versions.isEmpty) return null;
      
      final sorted = sortVersions(versions);
      return sorted.isNotEmpty ? sorted.last : null;
    } catch (e) {
      logger.error('Failed to get latest version: $e');
      return null;
    }
  }

  /// Check if version satisfies a constraint
  bool satisfiesConstraint(String version, String constraint) {
    try {
      final parsedVersion = parseVersion(version);
      if (parsedVersion == null) return false;
      
      final versionConstraint = VersionConstraint.parse(constraint);
      return versionConstraint.allows(parsedVersion);
    } catch (e) {
      logger.error('Failed to check version constraint: $version satisfies $constraint - $e');
      return false;
    }
  }

  /// Get next expected version for each upgrade type
  Map<VersionUpgradeType, String> getNextVersions(String currentVersion) {
    try {
      final current = parseVersion(currentVersion);
      if (current == null) return {};
      
      return {
        VersionUpgradeType.patch: Version(current.major, current.minor, current.patch + 1).toString(),
        VersionUpgradeType.minor: Version(current.major, current.minor + 1, 0).toString(),
        VersionUpgradeType.major: Version(current.major + 1, 0, 0).toString(),
      };
    } catch (e) {
      logger.error('Failed to get next versions: $currentVersion - $e');
      return {};
    }
  }

  /// Validate GitHub release tag format
  bool isValidGitHubReleaseTag(String tag) {
    // Common GitHub release tag patterns
    final patterns = [
      RegExp(r'^v?\d+\.\d+\.\d+$'), // v1.0.0 or 1.0.0
      RegExp(r'^v?\d+\.\d+\.\d+-\w+$'), // v1.0.0-beta
      RegExp(r'^v?\d+\.\d+\.\d+-\w+\.\d+$'), // v1.0.0-beta.1
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(tag));
  }

  /// Extract version from GitHub release name
  String? extractVersionFromReleaseName(String releaseName) {
    try {
      // Try to find version pattern in release name
      final versionPattern = RegExp(r'v?(\d+\.\d+\.\d+(?:-[\w\.]+)?)');
      final match = versionPattern.firstMatch(releaseName);
      
      if (match != null) {
        return match.group(1);
      }
      
      // If no pattern found, try to parse the whole string
      final parsed = parseVersion(releaseName);
      return parsed?.toString();
    } catch (e) {
      logger.error('Failed to extract version from release name: $releaseName - $e');
      return null;
    }
  }
}

/// Result of version comparison
enum VersionComparisonResult {
  newer,
  older,
  same,
  invalid,
}

/// Type of version upgrade
enum VersionUpgradeType {
  major,
  minor,
  patch,
  none,
  unknown,
}

/// Version components breakdown
class VersionComponents {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final String? build;
  final String originalString;
  final String cleanString;

  const VersionComponents({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
    this.build,
    required this.originalString,
    required this.cleanString,
  });

  @override
  String toString() {
    return 'VersionComponents(major: $major, minor: $minor, patch: $patch, '
           'preRelease: $preRelease, build: $build, original: $originalString)';
  }

  /// Get short display string
  String get shortDisplay => '$major.$minor.$patch';
  
  /// Get full display string
  String get fullDisplay {
    String display = shortDisplay;
    if (preRelease != null) display += '-$preRelease';
    if (build != null) display += '+$build';
    return display;
  }

  /// Check if this is a pre-release version
  bool get isPreRelease => preRelease != null;

  /// Check if this is a stable release
  bool get isStable => !isPreRelease;
}

/// Extension for easy version operations
extension VersionStringExtensions on String {
  /// Parse this string as a version
  Version? get asVersion => VersionUtils.instance.parseVersion(this);

  /// Check if this is a valid version
  bool get isValidVersion => VersionUtils.instance.isValidSemanticVersion(this);

  /// Check if this version is newer than another
  bool isNewerThan(String other) => VersionUtils.instance.isNewerVersion(other, this);

  /// Check if this version is older than another
  bool isOlderThan(String other) => VersionUtils.instance.isNewerVersion(this, other);

  /// Get version components
  VersionComponents? get versionComponents => VersionUtils.instance.getVersionComponents(this);

  /// Format for display
  String formatForDisplay({bool includePrefix = true}) {
    return VersionUtils.instance.formatVersionForDisplay(this, includePrefix: includePrefix);
  }
}