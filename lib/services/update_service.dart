import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import '../models/update_models.dart';
import '../utils/dio_config.dart';
import '../utils/logger_util.dart';

/// Service for handling app updates from GitHub releases
class UpdateService {
  static const String githubRepoOwner = 'CrossEvol';
  static const String githubRepoName = 'what_todo';
  static const String githubApiBaseUrl = 'https://api.github.com';

  final Dio _dio;
  PackageInfo? _packageInfo;

  UpdateService() : _dio = DioConfig.instance;

  /// Initialize package info
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      logger.info(
          'UpdateService initialized with app version: ${_packageInfo?.version}');
    } catch (e) {
      logger.error('Failed to initialize UpdateService: $e');
      rethrow;
    }
  }

  /// Get current app version
  String get currentVersion {
    return _packageInfo?.version ?? '0.0.0';
  }

  /// Get app name
  String get appName {
    return _packageInfo?.appName ?? 'What Todo';
  }

  /// Get package name
  String get packageName {
    return _packageInfo?.packageName ?? 'ja.burhanrashid52.whattodo';
  }

  /// Check for the latest release from GitHub
  Future<VersionInfo?> checkLatestVersion() async {
    try {
      logger.info('Checking for latest version from GitHub...');

      final response = await _dio.getWithErrorHandling<Map<String, dynamic>>(
        '$githubApiBaseUrl/repos/$githubRepoOwner/$githubRepoName/releases/latest',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response == null) {
        logger.warn('No response received from GitHub API');
        return null;
      }

      final versionInfo = VersionInfo.fromJson(response);
      logger.info('Latest version found: ${versionInfo.version}');

      return versionInfo;
    } on DioException catch (e) {
      logger.error('Network error while checking for updates: ${e.message}');
      throw UpdateException(
        'Failed to check for updates: ${e.message}',
        UpdateErrorType.networkError,
      );
    } catch (e) {
      logger.error('Unexpected error while checking for updates: $e');
      throw UpdateException(
        'Failed to check for updates: ${e.toString()}',
        UpdateErrorType.unknown,
      );
    }
  }

  /// Check if an update is available
  Future<bool> isUpdateAvailable() async {
    try {
      final latestVersion = await checkLatestVersion();
      if (latestVersion == null) return false;

      return isVersionNewer(latestVersion.version, currentVersion);
    } catch (e) {
      logger.error('Error checking if update is available: $e');
      return false;
    }
  }

  /// Compare two version strings
  bool isVersionNewer(String newVersion, String currentVersion) {
    try {
      // Remove 'v' prefix if present
      final cleanNew =
          newVersion.startsWith('v') ? newVersion.substring(1) : newVersion;
      final cleanCurrent = currentVersion.startsWith('v')
          ? currentVersion.substring(1)
          : currentVersion;

      final newVer = Version.parse(cleanNew);
      final currentVer = Version.parse(cleanCurrent);

      final isNewer = newVer > currentVer;
      logger.debug('Version comparison: $cleanCurrent vs $cleanNew = $isNewer');

      return isNewer;
    } catch (e) {
      logger.error('Error comparing versions: $e');
      // Fallback to simple string comparison
      return _fallbackVersionComparison(newVersion, currentVersion);
    }
  }

  /// Fallback version comparison using simple numeric comparison
  bool _fallbackVersionComparison(String newVersion, String currentVersion) {
    try {
      // Remove 'v' prefix if present
      final cleanNew =
          newVersion.startsWith('v') ? newVersion.substring(1) : newVersion;
      final cleanCurrent = currentVersion.startsWith('v')
          ? currentVersion.substring(1)
          : currentVersion;

      final newParts = cleanNew.split('.').map(int.parse).toList();
      final currentParts = cleanCurrent.split('.').map(int.parse).toList();

      // Pad with zeros to make lengths equal
      while (currentParts.length < newParts.length) currentParts.add(0);
      while (newParts.length < currentParts.length) newParts.add(0);

      for (int i = 0; i < currentParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      logger.error('Fallback version comparison failed: $e');
      return false;
    }
  }

  /// Get all releases (for testing and debugging)
  Future<List<VersionInfo>> getAllReleases() async {
    try {
      logger.info('Fetching all releases from GitHub...');

      final response = await _dio.getWithErrorHandling<List<dynamic>>(
        '$githubApiBaseUrl/repos/$githubRepoOwner/$githubRepoName/releases',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response == null) {
        logger.warn('No releases found');
        return [];
      }

      final releases = response
          .map((json) {
            try {
              return VersionInfo.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              logger.warn('Failed to parse release: $e');
              return null;
            }
          })
          .where((release) => release != null)
          .cast<VersionInfo>()
          .toList();

      logger.info('Found ${releases.length} valid releases');
      return releases;
    } on DioException catch (e) {
      logger.error('Network error while fetching releases: ${e.message}');
      throw UpdateException(
        'Failed to fetch releases: ${e.message}',
        UpdateErrorType.networkError,
      );
    } catch (e) {
      logger.error('Unexpected error while fetching releases: $e');
      throw UpdateException(
        'Failed to fetch releases: ${e.toString()}',
        UpdateErrorType.unknown,
      );
    }
  }

  /// Validate if a download URL is safe and accessible
  Future<bool> validateDownloadUrl(String url) async {
    try {
      final response = await _dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      logger.error('Download URL validation failed: $e');
      return false;
    }
  }

  /// Get file information from URL
  Future<Map<String, dynamic>?> getFileInfo(String url) async {
    try {
      final response = await _dio.head(url);
      if (response.statusCode == 200) {
        final contentLength = response.headers.value('content-length');
        final contentType = response.headers.value('content-type');
        final lastModified = response.headers.value('last-modified');

        return {
          'size': contentLength != null ? int.tryParse(contentLength) : null,
          'type': contentType,
          'lastModified': lastModified,
        };
      }
      return null;
    } catch (e) {
      logger.error('Failed to get file info: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    // Dio instance is managed by DioConfig, no need to dispose here
    logger.debug('UpdateService disposed');
  }
}

/// Custom exception for update-related errors
class UpdateException implements Exception {
  final String message;
  final UpdateErrorType errorType;
  final dynamic originalError;

  const UpdateException(
    this.message,
    this.errorType, [
    this.originalError,
  ]);

  @override
  String toString() => 'UpdateException: $message';
}

/// Extension for additional GitHub API functionality
extension GitHubApiExtensions on UpdateService {
  /// Get repository information
  Future<Map<String, dynamic>?> getRepositoryInfo() async {
    try {
      final response = await _dio.getWithErrorHandling<Map<String, dynamic>>(
        '${UpdateService.githubApiBaseUrl}/repos/${UpdateService.githubRepoOwner}/${UpdateService.githubRepoName}',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return response;
    } catch (e) {
      logger.error('Failed to get repository info: $e');
      return null;
    }
  }

  /// Check GitHub API rate limit
  Future<Map<String, dynamic>?> getRateLimit() async {
    try {
      final response = await _dio.getWithErrorHandling<Map<String, dynamic>>(
        '${UpdateService.githubApiBaseUrl}/rate_limit',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return response;
    } catch (e) {
      logger.error('Failed to get rate limit info: $e');
      return null;
    }
  }
}
