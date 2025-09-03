import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import '../models/update_models.dart';
import '../utils/logger_util.dart';

/// Manages APK downloads using flutter_downloader
@pragma('vm:entry-point')
class DownloadManager {
  static DownloadManager? _instance;

  static DownloadManager get instance {
    _instance ??= DownloadManager._internal();
    return _instance!;
  }

  DownloadManager._internal();

  final Map<String, String> _taskIds = {};
  final Map<String, DownloadProgress> _progressMap = {};
  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  ReceivePort? _port;
  bool _isInitialized = false;

  /// Stream of download progress updates
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Initialize the download manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await FlutterDownloader.initialize(debug: true);

      // Register callback
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      _port = ReceivePort();
      IsolateNameServer.registerPortWithName(
          _port!.sendPort, 'downloader_send_port');

      _port!.listen((dynamic data) {
        final taskId = data[0] as String;
        final status = DownloadTaskStatus.values[data[1] as int];
        final progress = data[2] as int;

        _handleDownloadUpdate(taskId, status, progress);
      });

      FlutterDownloader.registerCallback(downloadCallback);
      _isInitialized = true;

      logger.info('DownloadManager initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize DownloadManager: $e');
      rethrow;
    }
  }

  /// Download an APK file
  Future<String> startDownload({
    required String url,
    required String fileName,
    String? customPath,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Get download directory
      final directory = customPath ?? await _getDownloadDirectory();

      // Ensure directory exists
      final dir = Directory(directory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      logger.info('Starting download: $fileName from $url');

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory,
        fileName: fileName,
        headers: {'User-Agent': 'WhatTodo-UpdateManager/1.0'},
        showNotification: false,
        // We'll handle notifications ourselves
        openFileFromNotification: false,
      );

      if (taskId == null) {
        throw Exception('Failed to create download task');
      }

      // Store task mapping
      _taskIds[fileName] = taskId;

      // Create initial progress
      final progress = DownloadProgress(
        taskId: taskId,
        progress: 0.0,
        downloaded: 0,
        total: 0,
        // Will be updated when we get the first progress update
        fileName: fileName,
        status: DownloadStatus.pending,
      );

      _progressMap[taskId] = progress;
      _progressController.add(progress);

      logger.info('Download task created: $taskId for $fileName');
      return taskId;
    } catch (e) {
      logger.error('Failed to start download: $e');
      rethrow;
    }
  }

  /// Pause a download
  Future<void> pauseDownload(String taskId) async {
    try {
      await FlutterDownloader.pause(taskId: taskId);

      final progress = _progressMap[taskId];
      if (progress != null) {
        final updatedProgress =
            progress.copyWith(status: DownloadStatus.paused);
        _progressMap[taskId] = updatedProgress;
        _progressController.add(updatedProgress);
      }

      logger.info('Download paused: $taskId');
    } catch (e) {
      logger.error('Failed to pause download: $e');
      rethrow;
    }
  }

  /// Resume a download
  Future<void> resumeDownload(String taskId) async {
    try {
      final newTaskId = await FlutterDownloader.resume(taskId: taskId);

      if (newTaskId != null && newTaskId != taskId) {
        // Update task ID mapping if it changed
        final fileName = _getFileNameFromTaskId(taskId);
        if (fileName != null) {
          _taskIds[fileName] = newTaskId;
        }

        // Transfer progress data
        final progress = _progressMap.remove(taskId);
        if (progress != null) {
          final updatedProgress = progress.copyWith(
            taskId: newTaskId,
            status: DownloadStatus.downloading,
          );
          _progressMap[newTaskId] = updatedProgress;
          _progressController.add(updatedProgress);
        }
      }

      logger.info('Download resumed: $taskId (new ID: $newTaskId)');
    } catch (e) {
      logger.error('Failed to resume download: $e');
      rethrow;
    }
  }

  /// Cancel a download
  Future<void> cancelDownload(String taskId) async {
    try {
      await FlutterDownloader.cancel(taskId: taskId);

      final progress = _progressMap[taskId];
      if (progress != null) {
        final updatedProgress =
            progress.copyWith(status: DownloadStatus.cancelled);
        _progressMap[taskId] = updatedProgress;
        _progressController.add(updatedProgress);
      }

      // Clean up
      _progressMap.remove(taskId);
      final fileName = _getFileNameFromTaskId(taskId);
      if (fileName != null) {
        _taskIds.remove(fileName);
      }

      logger.info('Download canceled: $taskId');
    } catch (e) {
      logger.error('Failed to cancel download: $e');
      rethrow;
    }
  }

  /// Get download status
  Future<DownloadTaskStatus?> getDownloadStatus(String taskId) async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.where((task) => task.taskId == taskId).firstOrNull;
      return task?.status;
    } catch (e) {
      logger.error('Failed to get download status: $e');
      return null;
    }
  }

  /// Get all download tasks
  Future<List<DownloadTask>?> getAllTasks() async {
    try {
      return await FlutterDownloader.loadTasks();
    } catch (e) {
      logger.error('Failed to get all tasks: $e');
      return null;
    }
  }

  /// Remove a download task
  Future<void> removeTask(String taskId) async {
    try {
      await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);

      // Clean up
      _progressMap.remove(taskId);
      final fileName = _getFileNameFromTaskId(taskId);
      if (fileName != null) {
        _taskIds.remove(fileName);
      }

      logger.info('Download task removed: $taskId');
    } catch (e) {
      logger.error('Failed to remove task: $e');
      rethrow;
    }
  }

  /// Get download directory
  Future<String> _getDownloadDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Try to use external storage first
      directory = await getExternalStorageDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    return '${directory.path}/updates';
  }

  /// Handle download progress updates
  void _handleDownloadUpdate(
      String taskId, DownloadTaskStatus status, int progress) {
    try {
      final currentProgress = _progressMap[taskId];
      if (currentProgress == null) return;

      // Prevent processing if already completed to avoid infinite loops
      if (currentProgress.status == DownloadStatus.completed &&
          status == DownloadTaskStatus.complete) {
        return;
      }

      DownloadStatus downloadStatus;
      switch (status) {
        case DownloadTaskStatus.undefined:
          downloadStatus = DownloadStatus.pending;
          break;
        case DownloadTaskStatus.enqueued:
          downloadStatus = DownloadStatus.pending;
          break;
        case DownloadTaskStatus.running:
          downloadStatus = DownloadStatus.downloading;
          break;
        case DownloadTaskStatus.complete:
          downloadStatus = DownloadStatus.completed;
          break;
        case DownloadTaskStatus.failed:
          downloadStatus = DownloadStatus.failed;
          break;
        case DownloadTaskStatus.canceled:
          downloadStatus = DownloadStatus.cancelled;
          break;
        case DownloadTaskStatus.paused:
          downloadStatus = DownloadStatus.paused;
          break;
      }

      final progressValue = progress / 100.0;
      int downloadedBytes;

      if (status == DownloadTaskStatus.complete) {
        // For completed downloads, try to get actual file size
        _getActualFileSize(taskId).then((actualSize) {
          final bytes = actualSize ??
              (currentProgress.total > 0 ? currentProgress.total : 0);
          final finalProgress = currentProgress.copyWith(
            progress: 1.0,
            downloaded: bytes,
            total:
                bytes > currentProgress.total ? bytes : currentProgress.total,
            status: downloadStatus,
          );
          _progressMap[taskId] = finalProgress;
          _progressController.add(finalProgress);
        });
        return;
      } else {
        // For in-progress downloads, calculate based on progress
        downloadedBytes = currentProgress.total > 0
            ? (currentProgress.total * progressValue).round()
            : 0;
      }

      final updatedProgress = currentProgress.copyWith(
        progress: progressValue,
        downloaded: downloadedBytes,
        status: downloadStatus,
      );

      _progressMap[taskId] = updatedProgress;
      _progressController.add(updatedProgress);

      logger.debug(
          'Download progress: $taskId - ${(progressValue * 100).toStringAsFixed(1)}%');

      if (status == DownloadTaskStatus.complete) {
        logger.info('Download completed: $taskId');
      } else if (status == DownloadTaskStatus.failed) {
        logger.error('Download failed: $taskId');
      }
    } catch (e) {
      logger.error('Error handling download update: $e');
    }
  }

  /// Get actual file size for completed downloads
  Future<int?> _getActualFileSize(String taskId) async {
    try {
      final filePath = await getDownloadedFilePath(taskId);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          return await file.length();
        }
      }
      return null;
    } catch (e) {
      logger.error('Failed to get actual file size: $e');
      return null;
    }
  }

  /// Get file name from task ID
  String? _getFileNameFromTaskId(String taskId) {
    for (final entry in _taskIds.entries) {
      if (entry.value == taskId) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get the file path for a completed download
  Future<String?> getDownloadedFilePath(String taskId) async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      final task = tasks?.where((task) => task.taskId == taskId).firstOrNull;

      if (task != null && task.status == DownloadTaskStatus.complete) {
        return '${task.savedDir}/${task.filename}';
      }

      return null;
    } catch (e) {
      logger.error('Failed to get downloaded file path: $e');
      return null;
    }
  }

  /// Update file size for a task (called when we get file info)
  void updateFileSize(String taskId, int fileSize) {
    final progress = _progressMap[taskId];
    if (progress != null) {
      // Don't trigger updates for completed downloads to avoid loops
      if (progress.status == DownloadStatus.completed) {
        final updatedProgress = progress.copyWith(total: fileSize);
        _progressMap[taskId] = updatedProgress;
        // Don't emit to stream for completed downloads
        logger.debug('Updated file size for completed download: $taskId');
        return;
      }

      final updatedProgress = progress.copyWith(total: fileSize);
      _progressMap[taskId] = updatedProgress;
      _progressController.add(updatedProgress);
    }
  }

  /// Dispose resources
  void dispose() {
    _port?.close();
    _progressController.close();
    _progressMap.clear();
    _taskIds.clear();
    _isInitialized = false;
    logger.debug('DownloadManager disposed');
  }

  /// Static callback for flutter_downloader
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}

/// Extension for DownloadTaskStatus to DownloadStatus conversion
extension DownloadTaskStatusExtension on DownloadTaskStatus {
  DownloadStatus toDownloadStatus() {
    switch (this) {
      case DownloadTaskStatus.undefined:
      case DownloadTaskStatus.enqueued:
        return DownloadStatus.pending;
      case DownloadTaskStatus.running:
        return DownloadStatus.downloading;
      case DownloadTaskStatus.complete:
        return DownloadStatus.completed;
      case DownloadTaskStatus.failed:
        return DownloadStatus.failed;
      case DownloadTaskStatus.canceled:
        return DownloadStatus.cancelled;
      case DownloadTaskStatus.paused:
        return DownloadStatus.paused;
    }
  }
}
