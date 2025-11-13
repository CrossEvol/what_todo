import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
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

  /// Check camera permission status
  Future<bool> hasCameraPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      logger.error('Error checking camera permission: $e');
      return false;
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      logger.info('Requesting camera permission');
      final status = await Permission.camera.request();
      
      switch (status) {
        case PermissionStatus.granted:
          logger.info('Camera permission granted');
          return true;
        case PermissionStatus.denied:
          logger.warn('Camera permission denied');
          return false;
        case PermissionStatus.permanentlyDenied:
          logger.warn('Camera permission permanently denied');
          return false;
        case PermissionStatus.restricted:
          logger.warn('Camera permission restricted');
          return false;
        default:
          logger.warn('Camera permission status: $status');
          return false;
      }
    } catch (e) {
      logger.error('Error requesting camera permission: $e');
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
      
      // Use device_info_plus to get the exact SDK version
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.version.sdkInt >= 33;
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
  Future<void> openSettings() async {
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

  /// Show camera permission explanation dialog
  static Future<bool> showCameraPermissionDialog(BuildContext context) async {
    return await showPermissionDialog(
      context: context,
      title: 'Camera Permission Required',
      message: 'Camera access is needed to scan QR codes for GitHub configuration. '
               'This allows you to quickly import settings from another device.',
      confirmText: 'Grant Permission',
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

  /// Check and request storage permission for import/export with full UI flow
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      logger.info('Android SDK Version: $sdkVersion');

      if (sdkVersion >= 33) {
        // Android 13+ (API 33+) - request granular media permissions
        PermissionStatus imageStatus = await Permission.photos.status;

        if (imageStatus.isGranted) {
          return true;
        }

        if (imageStatus.isPermanentlyDenied) {
          _showPermissionSettingsDialog(context);
          return false;
        }

        // Request permission
        imageStatus = await Permission.photos.request();
        return imageStatus.isGranted;
      } else if (sdkVersion >= 30) {
        // Android 11-12 (API 30-32)
        PermissionStatus status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog(context);
          return false;
        }

        status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        }

        // Check if we need MANAGE_EXTERNAL_STORAGE
        bool hasFullAccess = await Permission.manageExternalStorage.isGranted;
        if (hasFullAccess) {
          return true;
        }

        // Show dialog to request full storage access
        bool shouldRequestFull = await _showRequestFullStorageDialog(context);
        if (shouldRequestFull) {
          await Permission.manageExternalStorage.request();
          hasFullAccess = await Permission.manageExternalStorage.isGranted;
          return hasFullAccess;
        }
        return false;
      } else {
        // Android 10 and below (API 29-)
        PermissionStatus status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog(context);
          return false;
        }

        status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      logger.error('Error checking/requesting storage permission: $e');
      return false;
    }
  }

  /// Show permission settings dialog
  void _showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'Storage permission is required for this feature. Please enable it in app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  /// Show request full storage dialog
  Future<bool> _showRequestFullStorageDialog(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Full Storage Access Required'),
        content: const Text(
          'This feature requires full access to storage. You will be redirected to settings to grant this permission.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Continue'),
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return result;
  }

  /// Check and request camera permission with full UI flow
  /// Returns true if permission is granted, false otherwise
  Future<bool> checkAndRequestCameraPermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      // Show explanation dialog
      final shouldRequest = await showCameraPermissionDialog(context);
      if (!shouldRequest) return false;

      // Request permission
      final granted = await requestCameraPermission();
      if (!granted) {
        _showPermissionDeniedDialog(context, 'Camera Permission');
        return false;
      }

      return true;
    } catch (e) {
      logger.error('Error checking/requesting camera permission: $e');
      return false;
    }
  }
}