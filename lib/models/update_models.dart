import 'package:equatable/equatable.dart';

/// Represents version information from GitHub release
class VersionInfo extends Equatable {
  final String version;
  final String downloadUrl;
  final String? releaseNotes;
  final DateTime publishedAt;
  final int? fileSize;
  final String fileName;
  final bool isPrerelease;

  const VersionInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    required this.fileSize,
    required this.fileName,
    this.isPrerelease = false,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    // Find APK asset
    final assets = json['assets'] as List<dynamic>? ?? [];
    final apkAsset = assets.firstWhere(
      (asset) => (asset['name'] as String).endsWith('.apk'),
      orElse: () => null,
    );

    if (apkAsset == null) {
      throw Exception('No APK file found in release assets');
    }

    return VersionInfo(
      version: json['tag_name'] as String,
      downloadUrl: apkAsset['browser_download_url'] as String,
      releaseNotes: json['body'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
      fileSize: apkAsset['size'] as int?,
      fileName: apkAsset['name'] as String,
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'downloadUrl': downloadUrl,
      'releaseNotes': releaseNotes,
      'publishedAt': publishedAt.toIso8601String(),
      'fileSize': fileSize,
      'fileName': fileName,
      'isPrerelease': isPrerelease,
    };
  }

  @override
  List<Object?> get props => [
        version,
        downloadUrl,
        releaseNotes,
        publishedAt,
        fileSize,
        fileName,
        isPrerelease,
      ];

  VersionInfo copyWith({
    String? version,
    String? downloadUrl,
    String? releaseNotes,
    DateTime? publishedAt,
    int? fileSize,
    String? fileName,
    bool? isPrerelease,
  }) {
    return VersionInfo(
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      publishedAt: publishedAt ?? this.publishedAt,
      fileSize: fileSize ?? this.fileSize,
      fileName: fileName ?? this.fileName,
      isPrerelease: isPrerelease ?? this.isPrerelease,
    );
  }

  /// Format file size in human readable format
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Check if this version is newer than current version
  bool isNewerThan(String currentVersion) {
    try {
      // Remove 'v' prefix if present
      final cleanCurrent = currentVersion.startsWith('v') 
          ? currentVersion.substring(1) 
          : currentVersion;
      final cleanNew = version.startsWith('v') 
          ? version.substring(1) 
          : version;
      
      final currentParts = cleanCurrent.split('.').map(int.parse).toList();
      final newParts = cleanNew.split('.').map(int.parse).toList();
      
      // Pad with zeros to make lengths equal
      while (currentParts.length < newParts.length) currentParts.add(0);
      while (newParts.length < currentParts.length) newParts.add(0);
      
      for (int i = 0; i < currentParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Represents download progress information
class DownloadProgress extends Equatable {
  final String taskId;
  final double progress; // 0.0 to 1.0
  final int downloaded;
  final int total;
  final String fileName;
  final DownloadStatus status;
  final String? error;
  final double? speed; // bytes per second
  final Duration? estimatedTimeRemaining;

  const DownloadProgress({
    required this.taskId,
    required this.progress,
    required this.downloaded,
    required this.total,
    required this.fileName,
    required this.status,
    this.error,
    this.speed,
    this.estimatedTimeRemaining,
  });

  @override
  List<Object?> get props => [
        taskId,
        progress,
        downloaded,
        total,
        fileName,
        status,
        error,
        speed,
        estimatedTimeRemaining,
      ];

  DownloadProgress copyWith({
    String? taskId,
    double? progress,
    int? downloaded,
    int? total,
    String? fileName,
    DownloadStatus? status,
    String? error,
    double? speed,
    Duration? estimatedTimeRemaining,
  }) {
    return DownloadProgress(
      taskId: taskId ?? this.taskId,
      progress: progress ?? this.progress,
      downloaded: downloaded ?? this.downloaded,
      total: total ?? this.total,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      error: error ?? this.error,
      speed: speed ?? this.speed,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
    );
  }

  /// Get progress percentage as integer
  int get progressPercentage => (progress * 100).round();

  /// Get progress percentage as double
  double get percentageComplete => progress * 100;

  /// Check if download is complete
  bool get isComplete => status == DownloadStatus.completed;

  /// Check if download has failed
  bool get hasFailed => status == DownloadStatus.failed;

  /// Get formatted speed string
  String get formattedSpeed {
    if (speed == null) return 'N/A';
    final speedValue = speed!;
    if (speedValue < 1024) return '${speedValue.toStringAsFixed(1)} B/s';
    if (speedValue < 1024 * 1024) return '${(speedValue / 1024).toStringAsFixed(1)} KB/s';
    return '${(speedValue / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Get formatted ETA string
  String get formattedETA {
    if (estimatedTimeRemaining == null) return 'N/A';
    final eta = estimatedTimeRemaining!;
    if (eta.inHours > 0) {
      return '${eta.inHours} hour(s) remaining';
    } else if (eta.inMinutes > 0) {
      return '${eta.inMinutes} minute(s) remaining';
    } else {
      return '${eta.inSeconds} seconds remaining';
    }
  }

  /// Get download speed (requires time measurement from caller)
  String getFormattedSpeed(Duration elapsed) {
    if (elapsed.inSeconds == 0) return '0 KB/s';
    final bytesPerSecond = downloaded / elapsed.inSeconds;
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    if (bytesPerSecond < 1024 * 1024) return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Format downloaded/total bytes
  String get formattedSize {
    final downloadedMB = downloaded / (1024 * 1024);
    final totalMB = total / (1024 * 1024);
    return '${downloadedMB.toStringAsFixed(1)}MB / ${totalMB.toStringAsFixed(1)}MB';
  }
}

/// Download status enumeration
enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Extension for DownloadStatus
extension DownloadStatusExtension on DownloadStatus {
  String get displayName {
    switch (this) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal {
    return this == DownloadStatus.completed ||
           this == DownloadStatus.failed ||
           this == DownloadStatus.cancelled;
  }

  bool get isActive {
    return !isTerminal;
  }
}

/// Update error types
enum UpdateErrorType {
  networkError,
  permissionDenied,
  downloadFailed,
  installationFailed,
  fileNotFound,
  invalidVersion,
  unknown,
}

/// Extension for UpdateErrorType
extension UpdateErrorTypeExtension on UpdateErrorType {
  String get displayName {
    switch (this) {
      case UpdateErrorType.networkError:
        return 'Network Error';
      case UpdateErrorType.permissionDenied:
        return 'Permission Denied';
      case UpdateErrorType.downloadFailed:
        return 'Download Failed';
      case UpdateErrorType.installationFailed:
        return 'Installation Failed';
      case UpdateErrorType.fileNotFound:
        return 'File Not Found';
      case UpdateErrorType.invalidVersion:
        return 'Invalid Version';
      case UpdateErrorType.unknown:
        return 'Unknown Error';
    }
  }

  String get description {
    switch (this) {
      case UpdateErrorType.networkError:
        return 'Please check your internet connection and try again.';
      case UpdateErrorType.permissionDenied:
        return 'The app needs permission to install updates.';
      case UpdateErrorType.downloadFailed:
        return 'Failed to download the update file.';
      case UpdateErrorType.installationFailed:
        return 'Failed to install the update.';
      case UpdateErrorType.fileNotFound:
        return 'The update file could not be found.';
      case UpdateErrorType.invalidVersion:
        return 'The version information is invalid.';
      case UpdateErrorType.unknown:
        return 'An unexpected error occurred.';
    }
  }

  bool get isRecoverable {
    switch (this) {
      case UpdateErrorType.networkError:
      case UpdateErrorType.downloadFailed:
      case UpdateErrorType.permissionDenied:
        return true;
      case UpdateErrorType.fileNotFound:
      case UpdateErrorType.invalidVersion:
      case UpdateErrorType.installationFailed:
      case UpdateErrorType.unknown:
        return false;
    }
  }
}

/// Update preferences model
class UpdatePreferences extends Equatable {
  final bool autoCheckEnabled;
  final bool autoDownload;
  final bool wifiOnlyDownload;
  final bool showNotifications;
  final DateTime? lastCheckTime;
  final List<String> skippedVersions;

  const UpdatePreferences({
    this.autoCheckEnabled = true,
    this.autoDownload = false,
    this.wifiOnlyDownload = true,
    this.showNotifications = true,
    this.lastCheckTime,
    this.skippedVersions = const [],
  });

  factory UpdatePreferences.fromJson(Map<String, dynamic> json) {
    return UpdatePreferences(
      autoCheckEnabled: json['autoCheckEnabled'] as bool? ?? true,
      autoDownload: json['autoDownload'] as bool? ?? false,
      wifiOnlyDownload: json['wifiOnlyDownload'] as bool? ?? true,
      showNotifications: json['showNotifications'] as bool? ?? true,
      lastCheckTime: json['lastCheckTime'] != null 
          ? DateTime.parse(json['lastCheckTime'] as String)
          : null,
      skippedVersions: (json['skippedVersions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoCheckEnabled': autoCheckEnabled,
      'autoDownload': autoDownload,
      'wifiOnlyDownload': wifiOnlyDownload,
      'showNotifications': showNotifications,
      'lastCheckTime': lastCheckTime?.toIso8601String(),
      'skippedVersions': skippedVersions,
    };
  }

  @override
  List<Object?> get props => [
        autoCheckEnabled,
        autoDownload,
        wifiOnlyDownload,
        showNotifications,
        lastCheckTime,
        skippedVersions,
      ];

  UpdatePreferences copyWith({
    bool? autoCheckEnabled,
    bool? autoDownload,
    bool? wifiOnlyDownload,
    bool? showNotifications,
    DateTime? lastCheckTime,
    List<String>? skippedVersions
  }) {
    return UpdatePreferences(
      autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
      autoDownload: autoDownload ?? this.autoDownload,
      wifiOnlyDownload: wifiOnlyDownload ?? this.wifiOnlyDownload,
      showNotifications: showNotifications ?? this.showNotifications,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
      skippedVersions: skippedVersions ?? this.skippedVersions,
    );
  }

  /// Check if a daily check is needed
  bool shouldPerformDailyCheck() {
    if (!autoCheckEnabled) return false;
    if (lastCheckTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCheckTime!);
    return difference.inHours >= 24;
  }

  /// Check if daily check is due (alias for shouldPerformDailyCheck)
  bool isDailyCheckDue() => shouldPerformDailyCheck();

  /// Check if a version is skipped
  bool isVersionSkipped(String version) {
    return skippedVersions.contains(version);
  }

  /// Add a version to skipped list
  UpdatePreferences addSkippedVersion(String version) {
    if (skippedVersions.contains(version)) {
      return this;
    }
    return copyWith(skippedVersions: [...skippedVersions, version]);
  }

  /// Remove a version from skipped list
  UpdatePreferences removeSkippedVersion(String version) {
    final newList = List<String>.from(skippedVersions);
    newList.remove(version);
    return copyWith(skippedVersions: newList);
  }

  /// Clear all skipped versions
  UpdatePreferences clearSkippedVersions() {
    return copyWith(skippedVersions: []);
  }
}