import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/update_models.dart';
import '../services/update_service.dart';
import '../utils/logger_util.dart';
import '../utils/shard_prefs_util.dart';

/// Repository for managing update operations and preferences
class UpdateRepository {
  static const String _prefsKey = 'update_preferences';
  static const String _lastCheckKey = 'last_update_check';
  
  final UpdateService _updateService;
  UpdatePreferences? _cachedPreferences;

  UpdateRepository({UpdateService? updateService})
      : _updateService = updateService ?? UpdateService();

  /// Initialize the repository
  Future<void> initialize() async {
    try {
      await _updateService.initialize();
      logger.info('UpdateRepository initialized');
    } catch (e) {
      logger.error('Failed to initialize UpdateRepository: $e');
      rethrow;
    }
  }

  /// Get current app version
  String get currentVersion => _updateService.currentVersion;

  /// Get app name
  String get appName => _updateService.appName;

  /// Check for updates with network connectivity check
  Future<VersionInfo?> checkForUpdates({bool isManual = false}) async {
    try {
      // Check network connectivity first
      if (!isManual && !await _hasNetworkConnection()) {
        logger.warn('No network connection available for update check');
        return null;
      }

      logger.info('Checking for updates${isManual ? ' (manual)' : ''}...');
      
      final versionInfo = await _updateService.checkLatestVersion();
      
      if (versionInfo != null) {
        // Update last check time
        await _updateLastCheckTime();
        logger.info('Update check completed. Latest version: ${versionInfo.version}');
      } else {
        logger.info('No version information received');
      }
      
      return versionInfo;
    } catch (e) {
      logger.error('Failed to check for updates: $e');
      rethrow;
    }
  }

  /// Check if an update is available
  Future<bool> isUpdateAvailable() async {
    try {
      return await _updateService.isUpdateAvailable();
    } catch (e) {
      logger.error('Failed to check if update is available: $e');
      return false;
    }
  }

  /// Compare two versions
  bool isVersionNewer(String newVersion, String currentVersion) {
    return _updateService.isVersionNewer(newVersion, currentVersion);
  }

  /// Validate download URL
  Future<bool> validateDownloadUrl(String url) async {
    try {
      return await _updateService.validateDownloadUrl(url);
    } catch (e) {
      logger.error('Failed to validate download URL: $e');
      return false;
    }
  }

  /// Get file information
  Future<Map<String, dynamic>?> getFileInfo(String url) async {
    try {
      return await _updateService.getFileInfo(url);
    } catch (e) {
      logger.error('Failed to get file info: $e');
      return null;
    }
  }

  /// Get update preferences
  Future<UpdatePreferences> getPreferences() async {
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }

    try {
      final prefsString = prefs.getString(_prefsKey);
      if (prefsString != null) {
        final prefsJson = jsonDecode(prefsString) as Map<String, dynamic>;
        _cachedPreferences = UpdatePreferences.fromJson(prefsJson);
      } else {
        _cachedPreferences = const UpdatePreferences();
      }
      
      logger.debug('Loaded update preferences: $_cachedPreferences');
      return _cachedPreferences!;
    } catch (e) {
      logger.error('Failed to load preferences, using defaults: $e');
      _cachedPreferences = const UpdatePreferences();
      return _cachedPreferences!;
    }
  }

  /// Save update preferences
  Future<void> savePreferences(UpdatePreferences preferences) async {
    try {
      final prefsString = jsonEncode(preferences.toJson());
      await prefs.setString(_prefsKey, prefsString);
      _cachedPreferences = preferences;
      logger.debug('Saved update preferences: $preferences');
    } catch (e) {
      logger.error('Failed to save preferences: $e');
      rethrow;
    }
  }

  /// Update last check time
  Future<void> _updateLastCheckTime() async {
    try {
      final now = DateTime.now();
      await prefs.setString(_lastCheckKey, now.toIso8601String());
      
      // Update cached preferences if available
      if (_cachedPreferences != null) {
        _cachedPreferences = _cachedPreferences!.copyWith(lastCheckTime: now);
        await savePreferences(_cachedPreferences!);
      }
      
      logger.debug('Updated last check time: $now');
    } catch (e) {
      logger.error('Failed to update last check time: $e');
    }
  }

  /// Get last check time
  Future<DateTime?> getLastCheckTime() async {
    try {
      final timeString = prefs.getString(_lastCheckKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      logger.error('Failed to get last check time: $e');
      return null;
    }
  }

  /// Check if daily update check is needed
  Future<bool> shouldPerformDailyCheck() async {
    try {
      final preferences = await getPreferences();
      return preferences.shouldPerformDailyCheck();
    } catch (e) {
      logger.error('Failed to check if daily check is needed: $e');
      return false;
    }
  }

  /// Skip a version
  Future<void> skipVersion(String version) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(skippedVersions: [version]);
      await savePreferences(updatedPreferences);
      logger.info('Skipped version: $version');
    } catch (e) {
      logger.error('Failed to skip version: $e');
      rethrow;
    }
  }

  /// Check if a version is skipped
  Future<bool> isVersionSkipped(String version) async {
    try {
      final preferences = await getPreferences();
      return preferences.skippedVersions.contains(version);
    } catch (e) {
      logger.error('Failed to check if version is skipped: $e');
      return false;
    }
  }

  /// Clear skipped version
  Future<void> clearSkippedVersion() async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(skippedVersions: null);
      await savePreferences(updatedPreferences);
      logger.info('Cleared skipped version');
    } catch (e) {
      logger.error('Failed to clear skipped version: $e');
    }
  }

  /// Toggle auto-check setting
  Future<void> toggleAutoCheck(bool enabled) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(autoCheckEnabled: enabled);
      await savePreferences(updatedPreferences);
      logger.info('Auto-check ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      logger.error('Failed to toggle auto-check: $e');
      rethrow;
    }
  }

  /// Toggle WiFi-only download setting
  Future<void> toggleWifiOnlyDownload(bool enabled) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(wifiOnlyDownload: enabled);
      await savePreferences(updatedPreferences);
      logger.info('WiFi-only download ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      logger.error('Failed to toggle WiFi-only download: $e');
      rethrow;
    }
  }

  /// Toggle notification setting
  Future<void> toggleNotifications(bool enabled) async {
    try {
      final preferences = await getPreferences();
      final updatedPreferences = preferences.copyWith(showNotifications: enabled);
      await savePreferences(updatedPreferences);
      logger.info('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      logger.error('Failed to toggle notifications: $e');
      rethrow;
    }
  }

  /// Check network connectivity
  Future<bool> _hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      logger.error('Failed to check network connectivity: $e');
      // Assume network is available if check fails
      return true;
    }
  }

  /// Check if device is connected to WiFi
  Future<bool> isConnectedToWifi() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      logger.error('Failed to check WiFi connectivity: $e');
      return false;
    }
  }

  /// Get repository information for debugging
  Future<Map<String, dynamic>?> getRepositoryInfo() async {
    try {
      return await _updateService.getRepositoryInfo();
    } catch (e) {
      logger.error('Failed to get repository info: $e');
      return null;
    }
  }

  /// Get GitHub API rate limit information
  Future<Map<String, dynamic>?> getRateLimit() async {
    try {
      return await _updateService.getRateLimit();
    } catch (e) {
      logger.error('Failed to get rate limit info: $e');
      return null;
    }
  }

  /// Reset all update-related data
  Future<void> reset() async {
    try {
      await prefs.remove(_prefsKey);
      await prefs.remove(_lastCheckKey);
      _cachedPreferences = null;
      logger.info('Reset all update data');
    } catch (e) {
      logger.error('Failed to reset update data: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _updateService.dispose();
    _cachedPreferences = null;
    logger.debug('UpdateRepository disposed');
  }
}