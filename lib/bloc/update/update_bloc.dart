import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/update_models.dart';
import '../../repositories/update_repository.dart';
import '../../utils/logger_util.dart';
import '../../utils/update_error_handler.dart';
import '../../utils/download_manager.dart';
import '../../utils/file_manager.dart';

part 'update_event.dart';
part 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final UpdateRepository _repository;
  final DownloadManager _downloadManager;
  final FileManager _fileManager;
  StreamSubscription? _downloadSubscription;

  UpdateBloc({
    UpdateRepository? repository,
    DownloadManager? downloadManager,
    FileManager? fileManager,
  }) : _repository = repository ?? UpdateRepository(),
       _downloadManager = downloadManager ?? DownloadManager.instance,
       _fileManager = fileManager ?? FileManager.instance,
       super(const UpdateInitial()) {
    on<CheckForUpdatesEvent>(_onCheckForUpdates);
    on<StartDownloadEvent>(_onStartDownload);
    on<PauseResumeDownloadEvent>(_onPauseResumeDownload);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<DownloadProgressEvent>(_onDownloadProgress);
    on<InstallUpdateEvent>(_onInstallUpdate);
    on<SkipVersionEvent>(_onSkipVersion);
    on<UpdatePreferencesEvent>(_onUpdatePreferences);
    on<DismissUpdateEvent>(_onDismissUpdate);
    on<RetryUpdateEvent>(_onRetryUpdate);
    on<ClearUpdateStateEvent>(_onClearUpdateState);

    _initialize();
  }

  /// Initialize the bloc
  Future<void> _initialize() async {
    try {
      await _repository.initialize();
      await _downloadManager.initialize();
      _listenToDownloadProgress();
      logger.info('UpdateBloc initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize UpdateBloc: $e');
      add(const CheckForUpdatesEvent(isManual: false));
    }
  }

  /// Listen to download progress from DownloadManager
  void _listenToDownloadProgress() {
    _downloadSubscription?.cancel();
    _downloadSubscription = _downloadManager.progressStream.listen((progress) {
      add(DownloadProgressEvent(progress));
    }, onError: (error) {
      logger.error('Error in download progress stream: $error');
      final currentState = state;
      if (currentState is UpdateDownloading) {
        add(const RetryUpdateEvent());
      }
    });
  }

  /// Handle check for updates event
  Future<void> _onCheckForUpdates(
    CheckForUpdatesEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      emit(UpdateChecking(isManual: event.isManual));
      logger.info('Checking for updates (manual: ${event.isManual})...');

      // Check if daily check is needed (for non-manual checks)
      if (!event.isManual) {
        final shouldCheck = await _repository.shouldPerformDailyCheck();
        if (!shouldCheck) {
          logger.debug('Daily check not needed, skipping...');
          emit(UpdateNotAvailable(lastChecked: DateTime.now()));
          return;
        }
      }

      final versionInfo = await _repository.checkForUpdates(isManual: event.isManual);
      
      if (versionInfo == null) {
        logger.info('No version information available');
        emit(UpdateNotAvailable(lastChecked: DateTime.now()));
        return;
      }

      // Check if this version is newer than current
      final currentVersion = _repository.currentVersion;
      final isNewer = _repository.isVersionNewer(versionInfo.version, currentVersion);
      
      if (!isNewer) {
        logger.info('No newer version available. Current: $currentVersion, Latest: ${versionInfo.version}');
        emit(UpdateNotAvailable(lastChecked: DateTime.now()));
        return;
      }

      // Check if this version was skipped
      final isSkipped = await _repository.isVersionSkipped(versionInfo.version);
      
      logger.info('Update available: ${versionInfo.version} (skipped: $isSkipped)');
      emit(UpdateAvailable(
        versionInfo: versionInfo,
        currentVersion: currentVersion,
        isSkipped: isSkipped,
      ));
    } catch (e, stackTrace) {
      logger.error('Error checking for updates: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'check_for_updates',
        context: {'isManual': event.isManual},
        stackTrace: stackTrace,
      );
      
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle start download event
  Future<void> _onStartDownload(
    StartDownloadEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      logger.info('Starting download for version: ${event.versionInfo.version}');

      // Validate download URL
      final isValidUrl = await _repository.validateDownloadUrl(event.versionInfo.downloadUrl);
      if (!isValidUrl) {
        emit(const UpdateError(
          message: 'Invalid download URL',
          errorType: UpdateErrorType.downloadFailed,
        ));
        return;
      }

      // Start download using DownloadManager
      final taskId = await _downloadManager.startDownload(
        url: event.versionInfo.downloadUrl,
        fileName: event.versionInfo.fileName,
      );

      // Update file size in DownloadManager if available
      if (event.versionInfo.fileSize != null && event.versionInfo.fileSize! > 0) {
        _downloadManager.updateFileSize(taskId, event.versionInfo.fileSize!);
      }

      // Create initial progress with actual taskId from DownloadManager
      final progress = DownloadProgress(
        taskId: taskId,
        progress: 0.0,
        downloaded: 0,
        total: event.versionInfo.fileSize ?? 0,
        fileName: event.versionInfo.fileName,
        status: DownloadStatus.pending,
      );

      emit(UpdateDownloading(
        versionInfo: event.versionInfo,
        progress: progress,
        startTime: DateTime.now(),
      ));

      logger.info('Download started for ${event.versionInfo.fileName} with task ID: $taskId');
    } catch (e, stackTrace) {
      logger.error('Error starting download: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'start_download',
        context: {
          'version': event.versionInfo.version,
          'fileName': event.versionInfo.fileName,
        },
        stackTrace: stackTrace,
      );
      
      final errorType = UpdateErrorHandler.instance.handleDownloadError(e);
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        errorType: errorType,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle pause/resume download event
  Future<void> _onPauseResumeDownload(
    PauseResumeDownloadEvent event,
    Emitter<UpdateState> emit,
  ) async {
    final currentState = state;
    if (currentState is UpdateDownloading) {
      try {
        logger.info('Pausing download: ${event.taskId}');
        await _downloadManager.pauseDownload(event.taskId);
        // State will be updated via progressStream
      } catch (e, stackTrace) {
        logger.error('Error pausing download: $e');
        UpdateErrorHandler.instance.logError(
          e,
          operation: 'pause_download',
          context: {'taskId': event.taskId},
          stackTrace: stackTrace,
        );
        emit(UpdateErrorHandler.instance.createErrorState(
          e,
          errorType: UpdateErrorType.downloadFailed,
          stackTrace: stackTrace,
        ));
      }
    } else if (currentState is UpdateDownloadPaused) {
      try {
        logger.info('Resuming download: ${event.taskId}');
        await _downloadManager.resumeDownload(event.taskId);
        // State will be updated via progressStream
      } catch (e, stackTrace) {
        logger.error('Error resuming download: $e');
        UpdateErrorHandler.instance.logError(
          e,
          operation: 'resume_download',
          context: {'taskId': event.taskId},
          stackTrace: stackTrace,
        );
        emit(UpdateErrorHandler.instance.createErrorState(
          e,
          errorType: UpdateErrorType.downloadFailed,
          stackTrace: stackTrace,
        ));
      }
    }
  }

  /// Handle cancel download event
  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      logger.info('Cancelling download: ${event.taskId}');
      await _downloadManager.cancelDownload(event.taskId);
      emit(const UpdateInitial());
    } catch (e, stackTrace) {
      logger.error('Error cancelling download: $e');
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'cancel_download',
        context: {'taskId': event.taskId},
        stackTrace: stackTrace,
      );
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        errorType: UpdateErrorType.downloadFailed,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle download progress event
  Future<void> _onDownloadProgress(
    DownloadProgressEvent event,
    Emitter<UpdateState> emit,
  ) async {
    final currentState = state;
    // Ensure we are in a state that expects progress updates for this task
    if ((currentState is UpdateDownloading && currentState.progress.taskId == event.progress.taskId) ||
        (currentState is UpdateDownloadPaused && currentState.progress.taskId == event.progress.taskId)) {
      
      if (event.progress.status == DownloadStatus.completed) {
        try {
          final filePath = await _downloadManager.getDownloadedFilePath(event.progress.taskId);
          if (filePath != null) {
            if (emit.isDone) return;
            if (currentState is UpdateDownloading) {
              emit(UpdateDownloaded(
                versionInfo: currentState.versionInfo,
                filePath: filePath,
                completedAt: DateTime.now(),
              ));
            } else if (currentState is UpdateDownloadPaused) {
              emit(UpdateDownloaded(
                versionInfo: currentState.versionInfo,
                filePath: filePath,
                completedAt: DateTime.now(),
              ));
            }
          } else {
            logger.error('Download completed but file path is null for task: ${event.progress.taskId}');
            if (emit.isDone) return;
            emit(const UpdateError(
              message: 'Download completed, but failed to retrieve file path.',
              errorType: UpdateErrorType.fileNotFound,
            ));
          }
        } catch (e, stackTrace) {
          logger.error('Error getting downloaded file path: $e');
          UpdateErrorHandler.instance.logError(
            e,
            operation: 'get_downloaded_file_path',
            context: {'taskId': event.progress.taskId},
            stackTrace: stackTrace,
          );
          if (emit.isDone) return;
          emit(UpdateErrorHandler.instance.createErrorState(
            e,
            errorType: UpdateErrorType.fileNotFound,
            stackTrace: stackTrace,
          ));
        }
      } else if (event.progress.status == DownloadStatus.failed) {
        emit(UpdateError(
          message: event.progress.error ?? 'Download failed',
          errorType: UpdateErrorType.downloadFailed,
        ));
      } else if (event.progress.status == DownloadStatus.cancelled) {
        emit(const UpdateInitial());
      } else if (event.progress.status == DownloadStatus.paused) {
        if (currentState is UpdateDownloading) {
          emit(UpdateDownloadPaused(
            versionInfo: currentState.versionInfo,
            progress: event.progress,
          ));
        } else if (currentState is UpdateDownloadPaused) {
          emit(currentState.copyWith(progress: event.progress));
        }
      } else if (event.progress.status == DownloadStatus.downloading) {
        if (currentState is UpdateDownloadPaused) {
          emit(UpdateDownloading(
            versionInfo: currentState.versionInfo,
            progress: event.progress,
            startTime: DateTime.now(),
          ));
        } else if (currentState is UpdateDownloading) {
          emit(currentState.copyWith(progress: event.progress));
        }
      } else {
        // For other statuses (pending), update progress
        if (currentState is UpdateDownloading) {
          emit(currentState.copyWith(progress: event.progress));
        } else if (currentState is UpdateDownloadPaused) {
          emit(currentState.copyWith(progress: event.progress));
        }
      }
    } else {
      logger.warn('Received progress for task ${event.progress.taskId} but current state is ${state.runtimeType} or task ID does not match.');
    }
  }

  /// Handle install update event
  Future<void> _onInstallUpdate(
    InstallUpdateEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! UpdateDownloaded) {
        emit(const UpdateError(
          message: 'No file available for installation',
          errorType: UpdateErrorType.fileNotFound,
        ));
        return;
      }

      logger.info('Installing update from: ${event.filePath}');
      emit(UpdateInstalling(
        versionInfo: currentState.versionInfo,
        filePath: event.filePath,
      ));

      // Check if file exists using FileManager for consistency
      if (!await _fileManager.fileExists(event.filePath)) {
        emit(UpdateError(
          message: 'Installation file not found at path: ${event.filePath}',
          errorType: UpdateErrorType.fileNotFound,
        ));
        return;
      }

      // Verify APK file (optional but recommended)
      final bool isApkValid = await _fileManager.verifyApkFile(event.filePath);
      if (!isApkValid) {
        emit(const UpdateError(
          message: 'APK file is invalid or corrupted',
          errorType: UpdateErrorType.installationFailed,
        ));
        return;
      }

      // Attempt to install the APK
      final installResult = await _fileManager.installApk(event.filePath);

      if (installResult.success) {
        logger.info('Installation initiated for ${currentState.versionInfo.version}: ${installResult.message}');
        emit(UpdateInstallationCompleted(versionInfo: currentState.versionInfo));
      } else {
        logger.error('Installation failed for ${currentState.versionInfo.version}: ${installResult.message}');
        emit(UpdateError(
          message: 'Installation failed: ${installResult.message}',
          errorType: UpdateErrorType.installationFailed,
        ));
      }
    } catch (e, stackTrace) {
      logger.error('Error installing update: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'install_update',
        context: {'filePath': event.filePath},
        stackTrace: stackTrace,
      );
      
      final errorType = UpdateErrorHandler.instance.handleInstallationError(e);
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        errorType: errorType,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle skip version event
  Future<void> _onSkipVersion(
    SkipVersionEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      await _repository.skipVersion(event.version);
      logger.info('Version skipped: ${event.version}');
      
      final currentState = state;
      if (currentState is UpdateAvailable) {
        emit(currentState.copyWith(isSkipped: true));
      } else {
        emit(const UpdateInitial());
      }
    } catch (e, stackTrace) {
      logger.error('Error skipping version: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'skip_version',
        context: {'version': event.version},
        stackTrace: stackTrace,
      );
      
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        customMessage: 'Failed to skip version: ${e.toString()}',
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle update preferences event
  Future<void> _onUpdatePreferences(
    UpdatePreferencesEvent event,
    Emitter<UpdateState> emit,
  ) async {
    try {
      await _repository.savePreferences(event.preferences);
      logger.info('Preferences updated: ${event.preferences}');
      
      // Emit current state wrapped with new preferences
      emit(UpdateWithPreferences(
        currentState: state,
        preferences: event.preferences,
      ));
    } catch (e, stackTrace) {
      logger.error('Error updating preferences: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'update_preferences',
        stackTrace: stackTrace,
      );
      
      emit(UpdateErrorHandler.instance.createErrorState(
        e,
        customMessage: 'Failed to update preferences: ${e.toString()}',
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle dismiss update event
  void _onDismissUpdate(
    DismissUpdateEvent event,
    Emitter<UpdateState> emit,
  ) {
    logger.debug('Update notification dismissed');
    emit(const UpdateInitial());
  }

  /// Handle retry update event
  void _onRetryUpdate(
    RetryUpdateEvent event,
    Emitter<UpdateState> emit,
  ) {
    logger.info('Retrying update operation...');
    add(const CheckForUpdatesEvent(isManual: true));
  }

  /// Handle clear update state event
  void _onClearUpdateState(
    ClearUpdateStateEvent event,
    Emitter<UpdateState> emit,
  ) {
    logger.debug('Clearing update state');
    emit(const UpdateInitial());
  }

  /// Perform daily check if needed
  Future<void> performDailyCheckIfNeeded() async {
    try {
      final shouldCheck = await _repository.shouldPerformDailyCheck();
      if (shouldCheck) {
        logger.info('Performing scheduled daily update check');
        add(const CheckForUpdatesEvent(isManual: false));
      }
    } catch (e, stackTrace) {
      logger.error('Error in daily check: $e');
      
      UpdateErrorHandler.instance.logError(
        e,
        operation: 'daily_check',
        stackTrace: stackTrace,
      );
    }
  }

  /// Get current preferences
  Future<UpdatePreferences> getPreferences() async {
    return await _repository.getPreferences();
  }

  /// Check if update notification should be shown
  bool shouldShowUpdateNotification() {
    final currentState = state;
    return currentState is UpdateAvailable && !currentState.isSkipped;
  }

  @override
  Future<void> close() {
    _downloadSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}