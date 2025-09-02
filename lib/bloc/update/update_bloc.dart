import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/update_models.dart';
import '../../repositories/update_repository.dart';
import '../../services/update_service.dart';
import '../../utils/logger_util.dart';
import '../../utils/update_error_handler.dart';

part 'update_event.dart';
part 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final UpdateRepository _repository;
  StreamSubscription? _downloadSubscription;

  UpdateBloc({UpdateRepository? repository})
      : _repository = repository ?? UpdateRepository(),
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
      logger.info('UpdateBloc initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize UpdateBloc: $e');
      add(const CheckForUpdatesEvent(isManual: false));
    }
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

      // Check WiFi requirement
      final preferences = await _repository.getPreferences();
      if (preferences.wifiOnlyDownload) {
        final isWifi = await _repository.isConnectedToWifi();
        if (!isWifi) {
          emit(const UpdateError(
            message: 'WiFi connection required for download',
            errorType: UpdateErrorType.networkError,
          ));
          return;
        }
      }

      // Validate download URL
      final isValidUrl = await _repository.validateDownloadUrl(event.versionInfo.downloadUrl);
      if (!isValidUrl) {
        emit(const UpdateError(
          message: 'Invalid download URL',
          errorType: UpdateErrorType.downloadFailed,
        ));
        return;
      }

      // Create initial progress
      final progress = DownloadProgress(
        taskId: 'update_${event.versionInfo.version}',
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

      // TODO: Start actual download using DownloadManager
      // This will be implemented in the download_manager_001 task
      logger.info('Download started for ${event.versionInfo.fileName}');
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
      logger.info('Pausing download: ${event.taskId}');
      emit(UpdateDownloadPaused(
        versionInfo: currentState.versionInfo,
        progress: currentState.progress,
      ));
      // TODO: Implement actual pause/resume logic
    } else if (currentState is UpdateDownloadPaused) {
      logger.info('Resuming download: ${event.taskId}');
      emit(UpdateDownloading(
        versionInfo: currentState.versionInfo,
        progress: currentState.progress,
        startTime: DateTime.now(),
      ));
      // TODO: Implement actual pause/resume logic
    }
  }

  /// Handle cancel download event
  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<UpdateState> emit,
  ) async {
    logger.info('Cancelling download: ${event.taskId}');
    // TODO: Implement actual cancel logic
    emit(const UpdateInitial());
  }

  /// Handle download progress event
  void _onDownloadProgress(
    DownloadProgressEvent event,
    Emitter<UpdateState> emit,
  ) {
    final currentState = state;
    if (currentState is UpdateDownloading) {
      if (event.progress.status == DownloadStatus.completed) {
        // TODO: Get actual file path from download manager
        emit(UpdateDownloaded(
          versionInfo: currentState.versionInfo,
          filePath: '/path/to/downloaded/file.apk', // Placeholder
          completedAt: DateTime.now(),
        ));
      } else if (event.progress.status == DownloadStatus.failed) {
        emit(UpdateError(
          message: event.progress.error ?? 'Download failed',
          errorType: UpdateErrorType.downloadFailed,
        ));
      } else {
        emit(currentState.copyWith(progress: event.progress));
      }
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

      // Check if file exists
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(const UpdateError(
          message: 'Installation file not found',
          errorType: UpdateErrorType.fileNotFound,
        ));
        return;
      }

      // TODO: Implement actual installation logic using FileManager
      // This will be implemented in the file_manager_001 task
      
      logger.info('Installation initiated for ${currentState.versionInfo.version}');
      emit(UpdateInstallationCompleted(versionInfo: currentState.versionInfo));
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