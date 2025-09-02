import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/update_models.dart';
import '../utils/logger_util.dart';

/// Service for managing download progress notifications
class NotificationService {
  static NotificationService? _instance;

  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _downloadChannelId = 'update_download_channel';
  static const String _downloadChannelName = 'Update Downloads';
  static const String _downloadChannelDescription =
      'Notifications for app update downloads';

  static const String _updateChannelId = 'update_available_channel';
  static const String _updateChannelName = 'App Updates';
  static const String _updateChannelDescription =
      'Notifications for available app updates';

  static const int _downloadNotificationId = 1001;
  static const int _updateAvailableNotificationId = 1002;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      logger.info('NotificationService initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Download progress channel
      const downloadChannel = AndroidNotificationChannel(
        _downloadChannelId,
        _downloadChannelName,
        description: _downloadChannelDescription,
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
        showBadge: false,
      );

      // Update available channel
      const updateChannel = AndroidNotificationChannel(
        _updateChannelId,
        _updateChannelName,
        description: _updateChannelDescription,
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(downloadChannel);
      await androidPlugin.createNotificationChannel(updateChannel);

      logger.debug('Notification channels created');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        logger.info('Android notification permission granted: $granted');
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        logger.info('iOS notification permission granted: $granted');
        return granted ?? false;
      }
    }

    return true; // Default to true for other platforms
  }

  /// Show download progress notification
  Future<void> showDownloadProgress(DownloadProgress progress) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final progressPercentage = progress.progressPercentage;
      final title = 'Updating ${progress.fileName}';
      String body;

      switch (progress.status) {
        case DownloadStatus.pending:
          body = 'Preparing download...';
          break;
        case DownloadStatus.downloading:
          body = '$progressPercentage% - ${progress.formattedSize}';
          break;
        case DownloadStatus.paused:
          body = 'Download paused at $progressPercentage%';
          break;
        case DownloadStatus.completed:
          body = 'Download completed';
          break;
        case DownloadStatus.failed:
          body = 'Download failed: ${progress.error ?? 'Unknown error'}';
          break;
        case DownloadStatus.cancelled:
          body = 'Download canceled';
          break;
      }

      final androidDetails = AndroidNotificationDetails(
        _downloadChannelId,
        _downloadChannelName,
        channelDescription: _downloadChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        showProgress: progress.status == DownloadStatus.downloading,
        maxProgress: 100,
        progress: progressPercentage,
        indeterminate: progress.status == DownloadStatus.pending,
        autoCancel: progress.status == DownloadStatus.completed ||
            progress.status == DownloadStatus.failed ||
            progress.status == DownloadStatus.cancelled,
        ongoing: progress.status == DownloadStatus.downloading ||
            progress.status == DownloadStatus.paused,
        enableVibration: false,
        playSound: false,
        actions: _getDownloadActions(progress.status),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _downloadNotificationId,
        title,
        body,
        notificationDetails,
        payload: 'download_progress:${progress.taskId}',
      );

      if (kDebugMode) {
        logger.debug(
            'Download progress notification shown: $progressPercentage%');
      }
    } catch (e) {
      logger.error('Failed to show download progress notification: $e');
    }
  }

  /// Show update available notification
  Future<void> showUpdateAvailable(
      VersionInfo versionInfo, String currentVersion) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const title = 'App Update Available';
      final body =
          'Version ${versionInfo.version} is now available (current: $currentVersion)';

      const androidDetails = AndroidNotificationDetails(
        _updateChannelId,
        _updateChannelName,
        channelDescription: _updateChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        enableVibration: true,
        playSound: true,
        actions: [
          AndroidNotificationAction(
            'update_now',
            'Update Now',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'update_later',
            'Later',
            showsUserInterface: false,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _updateAvailableNotificationId,
        title,
        body,
        notificationDetails,
        payload: 'update_available:${versionInfo.version}',
      );

      logger.info(
          'Update available notification shown for version: ${versionInfo.version}');
    } catch (e) {
      logger.error('Failed to show update available notification: $e');
    }
  }

  /// Cancel download progress notification
  Future<void> cancelDownloadNotification() async {
    try {
      await _notificationsPlugin.cancel(_downloadNotificationId);
      logger.debug('Download notification canceled');
    } catch (e) {
      logger.error('Failed to cancel download notification: $e');
    }
  }

  /// Cancel update available notification
  Future<void> cancelUpdateAvailableNotification() async {
    try {
      await _notificationsPlugin.cancel(_updateAvailableNotificationId);
      logger.debug('Update available notification canceled');
    } catch (e) {
      logger.error('Failed to cancel update available notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      logger.debug('All notifications canceled');
    } catch (e) {
      logger.error('Failed to cancel all notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true; // Assume enabled for other platforms
  }

  /// Get download actions based on status
  List<AndroidNotificationAction> _getDownloadActions(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return [
          const AndroidNotificationAction(
            'pause_download',
            'Pause',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'cancel_download',
            'Cancel',
            showsUserInterface: false,
          ),
        ];
      case DownloadStatus.paused:
        return [
          const AndroidNotificationAction(
            'resume_download',
            'Resume',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'cancel_download',
            'Cancel',
            showsUserInterface: false,
          ),
        ];
      case DownloadStatus.completed:
        return [
          const AndroidNotificationAction(
            'install_update',
            'Install',
            showsUserInterface: true,
          ),
        ];
      case DownloadStatus.failed:
        return [
          const AndroidNotificationAction(
            'retry_download',
            'Retry',
            showsUserInterface: false,
          ),
        ];
      default:
        return [];
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      final actionId = response.actionId;

      logger.info('Notification tapped - Action: $actionId, Payload: $payload');

      if (payload != null) {
        if (payload.startsWith('download_progress:')) {
          final taskId = payload.split(':')[1];
          _handleDownloadNotificationAction(actionId, taskId);
        } else if (payload.startsWith('update_available:')) {
          final version = payload.split(':')[1];
          _handleUpdateAvailableNotificationAction(actionId, version);
        }
      }
    } catch (e) {
      logger.error('Error handling notification tap: $e');
    }
  }

  /// Handle download notification actions
  void _handleDownloadNotificationAction(String? actionId, String taskId) {
    // TODO: Implement download action handling
    // This should communicate with the UpdateBloc to perform the appropriate action
    logger.info('Download notification action: $actionId for task: $taskId');

    switch (actionId) {
      case 'pause_download':
        // Dispatch pause download event to UpdateBloc
        break;
      case 'resume_download':
        // Dispatch resume download event to UpdateBloc
        break;
      case 'cancel_download':
        // Dispatch cancel download event to UpdateBloc
        break;
      case 'install_update':
        // Dispatch install update event to UpdateBloc
        break;
      case 'retry_download':
        // Dispatch retry download event to UpdateBloc
        break;
      default:
        // Handle notification tap without action (open app)
        break;
    }
  }

  /// Handle update available notification actions
  void _handleUpdateAvailableNotificationAction(
      String? actionId, String version) {
    // TODO: Implement update available action handling
    // This should communicate with the UpdateBloc to perform the appropriate action
    logger.info(
        'Update available notification action: $actionId for version: $version');

    switch (actionId) {
      case 'update_now':
        // Dispatch start download event to UpdateBloc
        break;
      case 'update_later':
        // Dismiss notification
        cancelUpdateAvailableNotification();
        break;
      default:
        // Handle notification tap without action (open app)
        break;
    }
  }

  /// Show a simple notification
  Future<void> showSimpleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _updateChannelId,
        _updateChannelName,
        channelDescription: _updateChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      logger.error('Failed to show simple notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    // Cancel all notifications
    cancelAllNotifications();
    _isInitialized = false;
    logger.debug('NotificationService disposed');
  }
}
