import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../utils/logger_util.dart';
import '../utils/permission_handler.dart';

/// Service for managing APK files and installation
class FileManager {
  static FileManager? _instance;
  static FileManager get instance {
    _instance ??= FileManager._internal();
    return _instance!;
  }

  FileManager._internal();

  /// Get the downloads directory for update files
  Future<Directory> getDownloadsDirectory() async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Try external storage first, fallback to app documents
        directory = await getExternalStorageDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final updatesDir = Directory(path.join(directory.path, 'updates'));

      // Ensure directory exists
      if (!await updatesDir.exists()) {
        await updatesDir.create(recursive: true);
        logger.debug('Created updates directory: ${updatesDir.path}');
      }

      return updatesDir;
    } catch (e) {
      logger.error('Error getting downloads directory: $e');
      rethrow;
    }
  }

  /// Get the full file path for a download
  Future<String> getDownloadFilePath(String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      return path.join(directory.path, fileName);
    } catch (e) {
      logger.error('Error getting download file path: $e');
      rethrow;
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      logger.debug('File exists check: $filePath = $exists');
      return exists;
    } catch (e) {
      logger.error('Error checking file existence: $e');
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        logger.debug('File size: $filePath = $size bytes');
        return size;
      }
      return 0;
    } catch (e) {
      logger.error('Error getting file size: $e');
      return 0;
    }
  }

  /// Get formatted file size string
  Future<String> getFormattedFileSize(String filePath) async {
    try {
      final size = await getFileSize(filePath);
      return _formatFileSize(size);
    } catch (e) {
      logger.error('Error getting formatted file size: $e');
      return '0 B';
    }
  }

  /// Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        logger.info('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      logger.error('Error deleting file: $e');
      return false;
    }
  }

  /// Clean up old update files
  Future<void> cleanupOldUpdateFiles({int maxAgeInDays = 7}) async {
    try {
      final directory = await getDownloadsDirectory();
      final files = await directory.list().toList();
      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));

      int deletedCount = 0;

      for (final fileEntity in files) {
        if (fileEntity is File) {
          final stat = await fileEntity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            try {
              await fileEntity.delete();
              deletedCount++;
              logger.debug('Deleted old update file: ${fileEntity.path}');
            } catch (e) {
              logger.warn('Failed to delete old file ${fileEntity.path}: $e');
            }
          }
        }
      }

      if (deletedCount > 0) {
        logger.info('Cleaned up $deletedCount old update files');
      }
    } catch (e) {
      logger.error('Error cleaning up old update files: $e');
    }
  }

  /// Install APK file
  Future<InstallResult> installApk(String filePath,
      {BuildContext? context}) async {
    try {
      logger.info('Starting APK installation: $filePath');

      // Check if file exists
      if (!await fileExists(filePath)) {
        logger.error('APK file not found: $filePath');
        return InstallResult.failure('APK file not found');
      }

      // Check permissions if context is provided
      if (context != null) {
        final hasPermission =
            await PermissionHandlerService.instance.hasInstallPermission();
        if (!hasPermission) {
          logger.warn('Install permission not granted');

          // Try to request permission
          final granted = await PermissionHandlerService.instance
              .requestPermissionsWithUI(context);
          if (!granted) {
            return InstallResult.failure('Install permission denied');
          }
        }
      }

      // Attempt to open/install the APK
      final result = await OpenFilex.open(filePath);

      logger.info(
          'APK installation initiated with result: ${result.type} - ${result.message}');

      switch (result.type) {
        case ResultType.done:
          return InstallResult.success('Installation started successfully');
        case ResultType.fileNotFound:
          return InstallResult.failure('APK file not found');
        case ResultType.noAppToOpen:
          return InstallResult.failure('No app available to install APK');
        case ResultType.permissionDenied:
          return InstallResult.failure('Permission denied for installation');
        case ResultType.error:
        return InstallResult.failure(result.message);
      }
    } catch (e) {
      logger.error('Error installing APK: $e');
      return InstallResult.failure('Installation failed: ${e.toString()}');
    }
  }

  /// Verify APK file integrity (basic check)
  Future<bool> verifyApkFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        logger.error('APK file does not exist: $filePath');
        return false;
      }

      // Check file size (should be greater than 1MB for a valid APK)
      final size = await file.length();
      if (size < 1024 * 1024) {
        logger.error('APK file too small: $size bytes');
        return false;
      }

      // Check file extension
      if (!filePath.toLowerCase().endsWith('.apk')) {
        logger.error('Invalid APK file extension: $filePath');
        return false;
      }

      // Basic file header check (APK files are ZIP files)
      final bytes = await file.openRead(0, 4).first;
      final header = String.fromCharCodes(bytes.take(2));
      if (header != 'PK') {
        logger.error('Invalid APK file header: $header');
        return false;
      }

      logger.debug('APK file verification passed: $filePath');
      return true;
    } catch (e) {
      logger.error('Error verifying APK file: $e');
      return false;
    }
  }

  /// Move file to a secure location (if needed)
  Future<String?> moveToSecureLocation(
      String sourcePath, String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      final securePath = path.join(directory.path, 'secure', fileName);

      // Create secure directory
      final secureDir = Directory(path.dirname(securePath));
      if (!await secureDir.exists()) {
        await secureDir.create(recursive: true);
      }

      // Move file
      final sourceFile = File(sourcePath);
      final targetFile = await sourceFile.copy(securePath);

      // Delete source file
      await sourceFile.delete();

      logger.info('File moved to secure location: $securePath');
      return targetFile.path;
    } catch (e) {
      logger.error('Error moving file to secure location: $e');
      return null;
    }
  }

  /// Get all APK files in downloads directory
  Future<List<FileInfo>> getDownloadedApkFiles() async {
    try {
      final directory = await getDownloadsDirectory();
      final files = await directory.list().toList();
      final apkFiles = <FileInfo>[];

      for (final fileEntity in files) {
        if (fileEntity is File &&
            fileEntity.path.toLowerCase().endsWith('.apk')) {
          final stat = await fileEntity.stat();
          final size = await fileEntity.length();

          apkFiles.add(FileInfo(
            path: fileEntity.path,
            name: path.basename(fileEntity.path),
            size: size,
            modifiedTime: stat.modified,
            formattedSize: _formatFileSize(size),
          ));
        }
      }

      // Sort by modification time (newest first)
      apkFiles.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));

      return apkFiles;
    } catch (e) {
      logger.error('Error getting downloaded APK files: $e');
      return [];
    }
  }

  /// Get total size of all downloaded files
  Future<int> getTotalDownloadedSize() async {
    try {
      final files = await getDownloadedApkFiles();
      return files.fold<int>(0, (total, file) => total + file.size);
    } catch (e) {
      logger.error('Error calculating total downloaded size: $e');
      return 0;
    }
  }

  /// Clear all downloaded files
  Future<int> clearAllDownloads() async {
    try {
      final files = await getDownloadedApkFiles();
      int deletedCount = 0;

      for (final file in files) {
        if (await deleteFile(file.path)) {
          deletedCount++;
        }
      }

      logger.info('Cleared $deletedCount downloaded files');
      return deletedCount;
    } catch (e) {
      logger.error('Error clearing downloads: $e');
      return 0;
    }
  }

  /// Show file in system file manager (if possible)
  Future<bool> showFileInManager(String filePath) async {
    try {
      // This might not work on all Android versions/file managers
      final result = await OpenFilex.open(path.dirname(filePath));
      return result.type == ResultType.done;
    } catch (e) {
      logger.error('Error showing file in manager: $e');
      return false;
    }
  }
}

/// Result class for installation operations
class InstallResult {
  final bool success;
  final String message;

  const InstallResult._(this.success, this.message);

  factory InstallResult.success(String message) =>
      InstallResult._(true, message);
  factory InstallResult.failure(String message) =>
      InstallResult._(false, message);

  @override
  String toString() => 'InstallResult(success: $success, message: $message)';
}

/// Information about a downloaded file
class FileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime modifiedTime;
  final String formattedSize;

  const FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.modifiedTime,
    required this.formattedSize,
  });

  @override
  String toString() =>
      'FileInfo(name: $name, size: $formattedSize, modified: $modifiedTime)';
}

/// Extension for easier file operations
extension FileManagerExtensions on FileManager {
  /// Quick install with user feedback
  Future<void> installApkWithFeedback(
    String filePath,
    BuildContext context, {
    VoidCallback? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      final result = await installApk(filePath, context: context);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        onSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
        onError?.call(result.message);
      }
    } catch (e) {
      final errorMessage = 'Installation failed: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      onError?.call(errorMessage);
    }
  }
}
