import 'dart:async';
import 'package:flutter/foundation.dart';
import '../bloc/update/update_bloc.dart';
import '../repositories/update_repository.dart';
import '../utils/logger_util.dart';

/// Service for scheduling automatic update checks
class UpdateSchedulerService {
  static UpdateSchedulerService? _instance;
  static UpdateSchedulerService get instance {
    _instance ??= UpdateSchedulerService._internal();
    return _instance!;
  }

  UpdateSchedulerService._internal();

  Timer? _periodicTimer;
  UpdateBloc? _updateBloc;
  UpdateRepository? _repository;
  bool _isInitialized = false;

  /// Initialize the scheduler service
  Future<void> initialize({
    required UpdateBloc updateBloc,
    UpdateRepository? repository,
  }) async {
    if (_isInitialized) return;

    try {
      _updateBloc = updateBloc;
      _repository = repository ?? UpdateRepository();
      
      // Perform initial check on app launch
      await _performInitialCheck();
      
      // Set up periodic checks (every 4 hours while app is running)
      _startPeriodicChecks();
      
      _isInitialized = true;
      logger.info('UpdateSchedulerService initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize UpdateSchedulerService: $e');
      rethrow;
    }
  }

  /// Perform initial update check when app launches
  Future<void> _performInitialCheck() async {
    try {
      if (_repository == null || _updateBloc == null) return;

      // Wait a bit to ensure app is fully loaded
      await Future.delayed(const Duration(seconds: 3));
      
      final shouldCheck = await _repository!.shouldPerformDailyCheck();
      if (shouldCheck) {
        logger.info('Performing initial daily update check');
        _updateBloc!.add(const CheckForUpdatesEvent(isManual: false));
      } else {
        logger.debug('Daily update check not needed yet');
      }
    } catch (e) {
      logger.error('Error in initial update check: $e');
    }
  }

  /// Start periodic update checks while app is running
  void _startPeriodicChecks() {
    // Check every 4 hours while app is running
    const checkInterval = Duration(hours: 4);
    
    _periodicTimer = Timer.periodic(checkInterval, (timer) async {
      try {
        if (_repository == null || _updateBloc == null) return;

        final shouldCheck = await _repository!.shouldPerformDailyCheck();
        if (shouldCheck) {
          logger.info('Performing scheduled update check');
          _updateBloc!.add(const CheckForUpdatesEvent(isManual: false));
        }
      } catch (e) {
        logger.error('Error in scheduled update check: $e');
      }
    });
    
    logger.debug('Periodic update checks started (every 4 hours)');
  }

  /// Perform an immediate check for updates
  Future<void> checkNow() async {
    try {
      if (_updateBloc == null) {
        logger.warn('UpdateBloc not available for immediate check');
        return;
      }

      logger.info('Performing immediate update check');
      _updateBloc!.add(const CheckForUpdatesEvent(isManual: true));
    } catch (e) {
      logger.error('Error in immediate update check: $e');
    }
  }

  /// Force a daily check regardless of last check time
  Future<void> forceDailyCheck() async {
    try {
      if (_updateBloc == null) {
        logger.warn('UpdateBloc not available for forced daily check');
        return;
      }

      logger.info('Forcing daily update check');
      _updateBloc!.add(const CheckForUpdatesEvent(isManual: false));
    } catch (e) {
      logger.error('Error in forced daily check: $e');
    }
  }

  /// Check if automatic updates are enabled
  Future<bool> isAutoUpdateEnabled() async {
    try {
      if (_repository == null) return true; // Default to enabled
      
      final preferences = await _repository!.getPreferences();
      return preferences.autoCheckEnabled;
    } catch (e) {
      logger.error('Error checking auto-update status: $e');
      return true; // Default to enabled on error
    }
  }

  /// Get time until next scheduled check
  Future<Duration?> getTimeUntilNextCheck() async {
    try {
      if (_repository == null) return null;
      
      final lastCheckTime = await _repository!.getLastCheckTime();
      if (lastCheckTime == null) return Duration.zero; // Check immediately
      
      final nextCheckTime = lastCheckTime.add(const Duration(hours: 24));
      final now = DateTime.now();
      
      if (nextCheckTime.isBefore(now)) {
        return Duration.zero; // Check immediately
      }
      
      return nextCheckTime.difference(now);
    } catch (e) {
      logger.error('Error calculating time until next check: $e');
      return null;
    }
  }

  /// Handle app lifecycle events
  void onAppResumed() {
    logger.debug('App resumed - checking if update check is needed');
    _performInitialCheck();
  }

  void onAppPaused() {
    logger.debug('App paused');
    // Could implement logic to schedule background checks here
  }

  /// Stop all scheduled checks
  void stopScheduledChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    logger.debug('Scheduled update checks stopped');
  }

  /// Restart scheduled checks
  void restartScheduledChecks() {
    stopScheduledChecks();
    _startPeriodicChecks();
    logger.debug('Scheduled update checks restarted');
  }

  /// Get scheduler status information
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'hasActiveTimer': _periodicTimer?.isActive ?? false,
      'blocAvailable': _updateBloc != null,
      'repositoryAvailable': _repository != null,
    };
  }

  /// Dispose resources
  void dispose() {
    stopScheduledChecks();
    _updateBloc = null;
    _repository = null;
    _isInitialized = false;
    logger.debug('UpdateSchedulerService disposed');
  }
}

/// Extension to integrate scheduler with app lifecycle
extension UpdateSchedulerAppLifecycle on UpdateSchedulerService {
  /// Initialize scheduler with app lifecycle awareness
  Future<void> initializeWithLifecycle({
    required UpdateBloc updateBloc,
    UpdateRepository? repository,
  }) async {
    await initialize(
      updateBloc: updateBloc,
      repository: repository,
    );

    // Could add WidgetsBindingObserver integration here for better lifecycle handling
    if (kDebugMode) {
      logger.debug('UpdateScheduler initialized with lifecycle awareness');
    }
  }
}