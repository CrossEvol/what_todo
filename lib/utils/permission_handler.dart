import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger_util.dart';

/// Service for handling Android app installation permissions
class PermissionHandlerService {
  static PermissionHandlerService? _instance;
  static PermissionHandlerService get instance {
    _instance ??= PermissionHandlerService._internal();
    return _instance!;
  }

  PermissionHandlerService._internal();

  /// Check if install unknown apps permission is granted
  Future<bool> hasInstallPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.requestInstallPackages.status;
      final hasPermission = status.isGranted;
      logger.debug('Install permission status: $status');
      return hasPermission;
    } catch (e) {
      logger.error('Error checking install permission: $e');
      return false;
    }
  }

  /// Request install unknown apps permission
  Future<bool> requestInstallPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      logger.info('Requesting install unknown apps permission');
      final status = await Permission.requestInstallPackages.request();
      
      switch (status) {
        case PermissionStatus.granted:
          logger.info('Install permission granted');
          return true;
        case PermissionStatus.denied:
          logger.warn('Install permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          logger.warn('Install permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          logger.warn('Install permission restricted');
          return false;
        default:
          logger.warn('Install permission status: $status');
          return false;
      }
    } catch (e) {
      logger.error('Error requesting install permission: $e');
      return false;
    }
  }

  /// Check notification permission status
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      logger.error('Error checking notification permission: $e');
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      logger.info('Requesting notification permission');
      final status = await Permission.notification.request();
      
      switch (status) {
        case PermissionStatus.granted:
          logger.info('Notification permission granted');
          return true;
        case PermissionStatus.denied:
          logger.warn('Notification permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          logger.warn('Notification permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          logger.warn('Notification permission restricted');
          return false;
        default:
          logger.warn('Notification permission status: $status');
          return false;
      }
    } catch (e) {
      logger.error('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check storage permission status
  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 13+ (API 33+), use specific media permissions
      if (await _isAndroid13OrHigher()) {
        final audioStatus = await Permission.audio.status;
        final videoStatus = await Permission.videos.status;
        final photoStatus = await Permission.photos.status;
        
        return audioStatus.isGranted || videoStatus.isGranted || photoStatus.isGranted;
      } else {
        // For older Android versions
        final status = await Permission.storage.status;
        return status.isGranted;
      }
    } catch (e) {
      logger.error('Error checking storage permission: $e');
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      logger.info('Requesting storage permission');
      
      // For Android 13+ (API 33+), request specific media permissions
      if (await _isAndroid13OrHigher()) {
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];
        
        final statuses = await permissions.request();
        return statuses.values.any((status) => status.isGranted);
      } else {
        // For older Android versions
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      logger.error('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if device is Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    try {
      if (!Platform.isAndroid) return false;
      
      // This is a simplified check - in a real app you might want to use
      // device_info_plus to get the exact SDK version
      return false; // For now, assume older Android
    } catch (e) {
      logger.error('Error checking Android version: $e');
      return false;
    }
  }

  /// Request all necessary permissions for the update process
  Future<Map<String, bool>> requestAllUpdatePermissions() async {
    final results = <String, bool>{};

    try {
      // Request install permission
      results['install'] = await requestInstallPermission();
      
      // Request notification permission
      results['notification'] = await requestNotificationPermission();
      
      // Request storage permission (for downloading APK)
      results['storage'] = await requestStoragePermission();
      
      logger.info('Permission request results: $results');
      return results;
    } catch (e) {
      logger.error('Error requesting update permissions: $e');
      return results;
    }
  }

  /// Check all necessary permissions for the update process
  Future<Map<String, bool>> checkAllUpdatePermissions() async {
    final results = <String, bool>{};

    try {
      // Check install permission
      results['install'] = await hasInstallPermission();
      
      // Check notification permission
      results['notification'] = await hasNotificationPermission();
      
      // Check storage permission
      results['storage'] = await hasStoragePermission();
      
      logger.debug('Permission check results: $results');
      return results;
    } catch (e) {
      logger.error('Error checking update permissions: $e');
      return results;
    }
  }

  /// Open app settings to manually grant permissions
  Future<void> openAppSettings() async {
    try {
      logger.info('Opening app settings for manual permission grant');
      await openAppSettings();
    } catch (e) {
      logger.error('Error opening app settings: $e');
    }
  }

  /// Show permission explanation dialog
  static Future<bool> showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Grant Permission',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show install permission explanation dialog
  static Future<bool> showInstallPermissionDialog(BuildContext context) async {
    return await showPermissionDialog(
      context: context,
      title: 'Install Permission Required',
      message: 'To install app updates, please allow installation from unknown sources. '
               'This permission is required to install the downloaded APK file.',
      confirmText: 'Grant Permission',
    );
  }

  /// Show notification permission explanation dialog
  static Future<bool> showNotificationPermissionDialog(BuildContext context) async {
    return await showPermissionDialog(
      context: context,
      title: 'Notification Permission',
      message: 'Allow notifications to receive update progress and completion alerts. '
               'You can disable this later in app settings.',
      confirmText: 'Allow Notifications',
      cancelText: 'Skip',
    );
  }

  /// Show storage permission explanation dialog
  static Future<bool> showStoragePermissionDialog(BuildContext context) async {
    return await showPermissionDialog(
      context: context,
      title: 'Storage Permission Required',
      message: 'Storage access is needed to download the update file. '
               'The APK will be saved temporarily and removed after installation.',
      confirmText: 'Grant Access',
    );
  }

  /// Complete permission flow with user interaction
  Future<bool> requestPermissionsWithUI(BuildContext context) async {
    try {
      // Check current permissions
      final currentPermissions = await checkAllUpdatePermissions();
      
      // Request install permission if needed
      if (!currentPermissions['install']!) {
        final shouldRequest = await showInstallPermissionDialog(context);
        if (!shouldRequest) return false;
        
        final granted = await requestInstallPermission();
        if (!granted) {
          _showPermissionDeniedDialog(context, 'Install Permission');
          return false;
        }
      }
      
      // Request notification permission if needed
      if (!currentPermissions['notification']!) {
        final shouldRequest = await showNotificationPermissionDialog(context);
        if (shouldRequest) {
          await requestNotificationPermission();
          // Don't block update flow if notification permission is denied
        }
      }
      
      // Request storage permission if needed
      if (!currentPermissions['storage']!) {
        final shouldRequest = await showStoragePermissionDialog(context);
        if (!shouldRequest) return false;
        
        final granted = await requestStoragePermission();
        if (!granted) {
          _showPermissionDeniedDialog(context, 'Storage Permission');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      logger.error('Error in permission flow: $e');
      return false;
    }
  }

  /// Show permission denied dialog with option to open settings
  void _showPermissionDeniedDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Denied'),
        content: Text(
          'This permission is required for app updates. '
          'You can grant it manually in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}