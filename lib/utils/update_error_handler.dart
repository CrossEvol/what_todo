import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../bloc/update/update_bloc.dart';
import '../utils/logger_util.dart';

/// Comprehensive error handling service for the update system
class UpdateErrorHandler {
  static UpdateErrorHandler? _instance;
  static UpdateErrorHandler get instance {
    _instance ??= UpdateErrorHandler._internal();
    return _instance!;
  }

  UpdateErrorHandler._internal();

  /// Handle network-related errors
  UpdateErrorType handleNetworkError(dynamic error) {
    if (error is DioException) {
      logger.error('Network error: ${error.type} - ${error.message}');
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return UpdateErrorType.networkError;
        case DioExceptionType.connectionError:
          return UpdateErrorType.networkError;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 400 && statusCode < 500) {
              return UpdateErrorType.invalidVersion;
            } else if (statusCode >= 500) {
              return UpdateErrorType.networkError;
            }
          }
          return UpdateErrorType.networkError;
        case DioExceptionType.cancel:
          return UpdateErrorType.unknown;
        case DioExceptionType.unknown:
        default:
          return UpdateErrorType.networkError;
      }
    }
    
    logger.error('Unknown network error: $error');
    return UpdateErrorType.networkError;
  }

  /// Handle download-related errors
  UpdateErrorType handleDownloadError(dynamic error, {String? additionalInfo}) {
    logger.error('Download error: $error ${additionalInfo != null ? '($additionalInfo)' : ''}');
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission')) {
      return UpdateErrorType.permissionDenied;
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return UpdateErrorType.networkError;
    } else if (errorString.contains('storage') || errorString.contains('space')) {
      return UpdateErrorType.downloadFailed;
    } else if (errorString.contains('file')) {
      return UpdateErrorType.fileNotFound;
    }
    
    return UpdateErrorType.downloadFailed;
  }

  /// Handle installation-related errors
  UpdateErrorType handleInstallationError(dynamic error, {String? additionalInfo}) {
    logger.error('Installation error: $error ${additionalInfo != null ? '($additionalInfo)' : ''}');
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission')) {
      return UpdateErrorType.permissionDenied;
    } else if (errorString.contains('file') && errorString.contains('not found')) {
      return UpdateErrorType.fileNotFound;
    } else if (errorString.contains('storage') || errorString.contains('space')) {
      return UpdateErrorType.installationFailed;
    }
    
    return UpdateErrorType.installationFailed;
  }

  /// Handle permission-related errors
  UpdateErrorType handlePermissionError(String permissionType) {
    logger.error('Permission error: $permissionType denied');
    return UpdateErrorType.permissionDenied;
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(UpdateErrorType errorType, {String? originalMessage}) {
    switch (errorType) {
      case UpdateErrorType.networkError:
        return 'Network connection failed. Please check your internet connection and try again.';
      case UpdateErrorType.permissionDenied:
        return 'Required permissions are not granted. Please grant the necessary permissions to continue.';
      case UpdateErrorType.downloadFailed:
        return 'Download failed. Please check your internet connection and available storage space.';
      case UpdateErrorType.installationFailed:
        return 'Installation failed. Please ensure you have enough storage space and try again.';
      case UpdateErrorType.fileNotFound:
        return 'Update file not found. Please download the update again.';
      case UpdateErrorType.invalidVersion:
        return 'Invalid version information. Please try checking for updates again.';
      case UpdateErrorType.unknown:
      return originalMessage ?? 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get suggested action for error recovery
  String getSuggestedAction(UpdateErrorType errorType) {
    switch (errorType) {
      case UpdateErrorType.networkError:
        return 'Check your internet connection and try again';
      case UpdateErrorType.permissionDenied:
        return 'Grant required permissions in app settings';
      case UpdateErrorType.downloadFailed:
        return 'Free up storage space and retry download';
      case UpdateErrorType.installationFailed:
        return 'Free up storage space and try installation again';
      case UpdateErrorType.fileNotFound:
        return 'Download the update file again';
      case UpdateErrorType.invalidVersion:
        return 'Check for updates again';
      case UpdateErrorType.unknown:
      return 'Restart the app and try again';
    }
  }

  /// Get error icon for UI display
  IconData getErrorIcon(UpdateErrorType errorType) {
    switch (errorType) {
      case UpdateErrorType.networkError:
        return Icons.wifi_off;
      case UpdateErrorType.permissionDenied:
        return Icons.security;
      case UpdateErrorType.downloadFailed:
        return Icons.download;
      case UpdateErrorType.installationFailed:
        return Icons.install_mobile;
      case UpdateErrorType.fileNotFound:
        return Icons.file_present;
      case UpdateErrorType.invalidVersion:
        return Icons.info;
      case UpdateErrorType.unknown:
      return Icons.error;
    }
  }

  /// Show error dialog with appropriate actions
  static Future<void> showErrorDialog({
    required BuildContext context,
    required UpdateErrorType errorType,
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    final handler = UpdateErrorHandler.instance;
    final userMessage = handler.getUserFriendlyMessage(errorType, originalMessage: message);
    final suggestedAction = handler.getSuggestedAction(errorType);
    final icon = handler.getErrorIcon(errorType);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Update Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userMessage),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Suggestion: $suggestedAction',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: const Text('Cancel'),
              ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            if (onRetry == null && onCancel == null)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar({
    required BuildContext context,
    required UpdateErrorType errorType,
    String? message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    final handler = UpdateErrorHandler.instance;
    final userMessage = handler.getUserFriendlyMessage(errorType, originalMessage: message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              handler.getErrorIcon(errorType),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(userMessage)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 6),
        action: onActionPressed != null
            ? SnackBarAction(
                label: actionLabel ?? 'Retry',
                textColor: Colors.white,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  /// Create error state for BLoC
  UpdateError createErrorState(
    dynamic error, {
    UpdateErrorType? errorType,
    String? customMessage,
    StackTrace? stackTrace,
  }) {
    UpdateErrorType type;
    String message;

    if (errorType != null) {
      type = errorType;
      message = customMessage ?? getUserFriendlyMessage(type);
    } else if (error is DioException) {
      type = handleNetworkError(error);
      message = getUserFriendlyMessage(type);
    } else {
      type = UpdateErrorType.unknown;
      message = customMessage ?? error.toString();
    }

    return UpdateError(
      message: message,
      errorType: type,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error with context
  void logError(
    dynamic error, {
    required String operation,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    final contextInfo = context != null ? ' Context: $context' : '';
    logger.error('Update operation failed: $operation - $error$contextInfo', message: stackTrace);
  }

  /// Check if error is recoverable
  bool isRecoverableError(UpdateErrorType errorType) {
    switch (errorType) {
      case UpdateErrorType.networkError:
      case UpdateErrorType.downloadFailed:
      case UpdateErrorType.invalidVersion:
        return true;
      case UpdateErrorType.permissionDenied:
      case UpdateErrorType.installationFailed:
      case UpdateErrorType.fileNotFound:
        return false;
      case UpdateErrorType.unknown:
      return true; // Give it a chance
    }
  }

  /// Get retry delay for automatic retries
  Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 2 * attemptNumber);
    final jitter = Duration(milliseconds: (attemptNumber * 500));
    return baseDelay + jitter;
  }

  /// Should attempt automatic retry
  bool shouldAutoRetry(UpdateErrorType errorType, int attemptCount) {
    if (attemptCount >= 3) return false;
    
    switch (errorType) {
      case UpdateErrorType.networkError:
      case UpdateErrorType.downloadFailed:
        return true;
      case UpdateErrorType.permissionDenied:
      case UpdateErrorType.installationFailed:
      case UpdateErrorType.fileNotFound:
      case UpdateErrorType.invalidVersion:
      case UpdateErrorType.unknown:
        return false;
    }
  }
}

/// Extension for easy error handling in BLoCs
extension UpdateErrorHandling on dynamic {
  UpdateError toUpdateError({String? customMessage, StackTrace? stackTrace}) {
    return UpdateErrorHandler.instance.createErrorState(
      this,
      customMessage: customMessage,
      stackTrace: stackTrace,
    );
  }
}

/// Mixin for widgets that need error handling
mixin UpdateErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void handleUpdateError(
    UpdateErrorType errorType, {
    String? message,
    bool showDialog = false,
    VoidCallback? onRetry,
  }) {
    if (showDialog) {
      UpdateErrorHandler.showErrorDialog(
        context: context,
        errorType: errorType,
        message: message,
        onRetry: onRetry,
      );
    } else {
      UpdateErrorHandler.showErrorSnackbar(
        context: context,
        errorType: errorType,
        message: message,
        onActionPressed: onRetry,
      );
    }
  }
}

/// Error recovery strategies
class ErrorRecoveryStrategy {
  static Map<UpdateErrorType, List<String>> getRecoverySteps() {
    return {
      UpdateErrorType.networkError: [
        'Check your internet connection',
        'Try switching between WiFi and mobile data',
        'Restart your network connection',
        'Try again later when connection is stable',
      ],
      UpdateErrorType.permissionDenied: [
        'Open app settings',
        'Grant required permissions',
        'Restart the app if needed',
        'Try the update process again',
      ],
      UpdateErrorType.downloadFailed: [
        'Check available storage space',
        'Close other apps to free up memory',
        'Try downloading over WiFi',
        'Clear app cache if needed',
      ],
      UpdateErrorType.installationFailed: [
        'Ensure you have enough storage space',
        'Check install permissions are granted',
        'Try restarting your device',
        'Download the update again if needed',
      ],
      UpdateErrorType.fileNotFound: [
        'Download the update file again',
        'Check if the file was moved or deleted',
        'Clear app cache and retry',
        'Contact support if problem persists',
      ],
      UpdateErrorType.invalidVersion: [
        'Check for updates again',
        'Verify your internet connection',
        'Try again in a few minutes',
        'Contact support if problem persists',
      ],
      UpdateErrorType.unknown: [
        'Restart the app',
        'Check your internet connection',
        'Try again later',
        'Contact support if problem persists',
      ],
    };
  }
}