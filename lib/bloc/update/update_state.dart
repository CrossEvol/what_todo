part of 'update_bloc.dart';

abstract class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

/// Checking for updates
class UpdateChecking extends UpdateState {
  final bool isManual;

  const UpdateChecking({this.isManual = false});

  @override
  List<Object?> get props => [isManual];
}

/// No update available
class UpdateNotAvailable extends UpdateState {
  final DateTime lastChecked;

  const UpdateNotAvailable({required this.lastChecked});

  @override
  List<Object?> get props => [lastChecked];
}

/// Update is available
class UpdateAvailable extends UpdateState {
  final VersionInfo versionInfo;
  final String currentVersion;
  final bool isSkipped;

  const UpdateAvailable({
    required this.versionInfo,
    required this.currentVersion,
    this.isSkipped = false,
  });

  @override
  List<Object?> get props => [versionInfo, currentVersion, isSkipped];

  UpdateAvailable copyWith({
    VersionInfo? versionInfo,
    String? currentVersion,
    bool? isSkipped,
  }) {
    return UpdateAvailable(
      versionInfo: versionInfo ?? this.versionInfo,
      currentVersion: currentVersion ?? this.currentVersion,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }
}

/// Download is in progress
class UpdateDownloading extends UpdateState {
  final VersionInfo versionInfo;
  final DownloadProgress progress;
  final DateTime startTime;

  const UpdateDownloading({
    required this.versionInfo,
    required this.progress,
    required this.startTime,
  });

  @override
  List<Object?> get props => [versionInfo, progress, startTime];

  UpdateDownloading copyWith({
    VersionInfo? versionInfo,
    DownloadProgress? progress,
    DateTime? startTime,
  }) {
    return UpdateDownloading(
      versionInfo: versionInfo ?? this.versionInfo,
      progress: progress ?? this.progress,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Calculate download speed
  String get downloadSpeed {
    final elapsed = DateTime.now().difference(startTime);
    return progress.getFormattedSpeed(elapsed);
  }

  /// Calculate estimated time remaining
  String get estimatedTimeRemaining {
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds == 0 || progress.progress == 0) return 'Calculating...';
    
    final totalSeconds = elapsed.inSeconds / progress.progress;
    final remainingSeconds = totalSeconds - elapsed.inSeconds;
    
    if (remainingSeconds < 60) return '${remainingSeconds.round()}s';
    if (remainingSeconds < 3600) return '${(remainingSeconds / 60).round()}m';
    return '${(remainingSeconds / 3600).round()}h';
  }
}

/// Download is paused
class UpdateDownloadPaused extends UpdateState {
  final VersionInfo versionInfo;
  final DownloadProgress progress;

  const UpdateDownloadPaused({
    required this.versionInfo,
    required this.progress,
  });

  @override
  List<Object?> get props => [versionInfo, progress];

  UpdateDownloadPaused copyWith({
    VersionInfo? versionInfo,
    DownloadProgress? progress,
  }) {
    return UpdateDownloadPaused(
      versionInfo: versionInfo ?? this.versionInfo,
      progress: progress ?? this.progress,
    );
  }
}

/// Download completed successfully
class UpdateDownloaded extends UpdateState {
  final VersionInfo versionInfo;
  final String filePath;
  final DateTime completedAt;

  const UpdateDownloaded({
    required this.versionInfo,
    required this.filePath,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [versionInfo, filePath, completedAt];
}

/// Installing update
class UpdateInstalling extends UpdateState {
  final VersionInfo versionInfo;
  final String filePath;

  const UpdateInstalling({
    required this.versionInfo,
    required this.filePath,
  });

  @override
  List<Object?> get props => [versionInfo, filePath];
}

/// Update installation completed (app should restart)
class UpdateInstallationCompleted extends UpdateState {
  final VersionInfo versionInfo;

  const UpdateInstallationCompleted({required this.versionInfo});

  @override
  List<Object?> get props => [versionInfo];
}

/// Error occurred during update process
class UpdateError extends UpdateState {
  final String message;
  final UpdateErrorType errorType;
  final dynamic error;
  final StackTrace? stackTrace;

  const UpdateError({
    required this.message,
    required this.errorType,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, errorType, error, stackTrace];

  UpdateError copyWith({
    String? message,
    UpdateErrorType? errorType,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return UpdateError(
      message: message ?? this.message,
      errorType: errorType ?? this.errorType,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Types of update errors
enum UpdateErrorType {
  networkError,
  permissionDenied,
  downloadFailed,
  installationFailed,
  fileNotFound,
  invalidVersion,
  unknown,
}

/// State with preferences loaded
class UpdateWithPreferences extends UpdateState {
  final UpdateState currentState;
  final UpdatePreferences preferences;

  const UpdateWithPreferences({
    required this.currentState,
    required this.preferences,
  });

  @override
  List<Object?> get props => [currentState, preferences];

  UpdateWithPreferences copyWith({
    UpdateState? currentState,
    UpdatePreferences? preferences,
  }) {
    return UpdateWithPreferences(
      currentState: currentState ?? this.currentState,
      preferences: preferences ?? this.preferences,
    );
  }
}