import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/update/update_bloc.dart';
import '../models/update_models.dart' hide UpdateErrorType;

/// Dialog widget for showing update information and actions
class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final String currentVersion;
  final bool isSkipped;

  const UpdateDialog({
    Key? key,
    required this.versionInfo,
    required this.currentVersion,
    this.isSkipped = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('App Update Available'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionInfo(context),
            const SizedBox(height: 16),
            _buildFileInfo(context),
            const SizedBox(height: 16),
            _buildReleaseNotes(context),
            if (isSkipped) ...[
              const SizedBox(height: 12),
              _buildSkippedWarning(context),
            ],
          ],
        ),
      ),
      actions: _buildActions(context),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Version:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currentVersion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Version:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                versionInfo.version,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.file_download,
          size: 16,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${versionInfo.fileName} (${versionInfo.formattedFileSize})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseNotes(BuildContext context) {
    if (versionInfo.releaseNotes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s New:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: SingleChildScrollView(
            child: Text(
              versionInfo.releaseNotes!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkippedWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This version was previously skipped',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      // Skip version button
      TextButton(
        onPressed: () {
          context.read<UpdateBloc>().add(SkipVersionEvent(versionInfo.version));
          Navigator.of(context).pop();
        },
        child: Text(
          'Skip Version',
          style: TextStyle(
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
      // Later button
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Later'),
      ),
      // Update now button
      ElevatedButton.icon(
        onPressed: () {
          context.read<UpdateBloc>().add(StartDownloadEvent(versionInfo));
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.download),
        label: const Text('Update Now'),
      ),
    ];
  }

  /// Show the update dialog
  static Future<void> show(
    BuildContext context, {
    required VersionInfo versionInfo,
    required String currentVersion,
    bool isSkipped = false,
  }) {
    HapticFeedback.lightImpact();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        versionInfo: versionInfo,
        currentVersion: currentVersion,
        isSkipped: isSkipped,
      ),
    );
  }
}

/// Progress dialog for showing download progress
class UpdateProgressDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final DownloadProgress progress;
  final DateTime startTime;

  const UpdateProgressDialog({
    Key? key,
    required this.versionInfo,
    required this.progress,
    required this.startTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.download,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Downloading Update'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFileInfo(context),
          const SizedBox(height: 16),
          _buildProgressBar(context),
          const SizedBox(height: 12),
          _buildProgressDetails(context),
        ],
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Version ${versionInfo.version}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          versionInfo.fileName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.progressPercentage}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.progress,
          backgroundColor: Theme.of(context).dividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    final elapsed = DateTime.now().difference(startTime);
    final speed = progress.getFormattedSpeed(elapsed);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloaded:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              progress.formattedSize,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Speed:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              speed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (progress.status) {
      case DownloadStatus.downloading:
        return [
          TextButton(
            onPressed: () {
              context.read<UpdateBloc>().add(CancelDownloadEvent(progress.taskId));
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UpdateBloc>().add(PauseResumeDownloadEvent(progress.taskId));
            },
            child: const Text('Pause'),
          ),
        ];
      case DownloadStatus.paused:
        return [
          TextButton(
            onPressed: () {
              context.read<UpdateBloc>().add(CancelDownloadEvent(progress.taskId));
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UpdateBloc>().add(PauseResumeDownloadEvent(progress.taskId));
            },
            child: const Text('Resume'),
          ),
        ];
      case DownloadStatus.completed:
        return [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Install'),
          ),
        ];
      case DownloadStatus.failed:
        return [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UpdateBloc>().add(StartDownloadEvent(versionInfo));
            },
            child: const Text('Retry'),
          ),
        ];
      default:
        return [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ];
    }
  }

  String _getStatusText() {
    switch (progress.status) {
      case DownloadStatus.pending:
        return 'Preparing...';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Canceled';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (progress.status) {
      case DownloadStatus.downloading:
        return Theme.of(context).primaryColor;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
      case DownloadStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      case DownloadStatus.paused:
        return Colors.orange;
      default:
        return Theme.of(context).hintColor;
    }
  }

  Color _getProgressColor(BuildContext context) {
    switch (progress.status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Theme.of(context).colorScheme.error;
      case DownloadStatus.paused:
        return Colors.orange;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  /// Show the progress dialog
  static Future<void> show(
    BuildContext context, {
    required VersionInfo versionInfo,
    required DownloadProgress progress,
    required DateTime startTime,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateProgressDialog(
        versionInfo: versionInfo,
        progress: progress,
        startTime: startTime,
      ),
    );
  }
}

/// Simple error dialog for update-related errors
class UpdateErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final UpdateErrorType errorType;
  final VoidCallback? onRetry;

  const UpdateErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.errorType,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          _buildErrorTypeInfo(context),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text('Retry'),
          ),
      ],
    );
  }

  Widget _buildErrorTypeInfo(BuildContext context) {
    String info;
    IconData icon;
    
    switch (errorType) {
      case UpdateErrorType.networkError:
        info = 'Check your internet connection and try again.';
        icon = Icons.wifi_off;
        break;
      case UpdateErrorType.permissionDenied:
        info = 'Please grant the required permissions.';
        icon = Icons.security;
        break;
      case UpdateErrorType.downloadFailed:
        info = 'The download was interrupted or failed.';
        icon = Icons.download;
        break;
      case UpdateErrorType.installationFailed:
        info = 'Installation failed. Check if you have enough storage space.';
        icon = Icons.install_mobile;
        break;
      case UpdateErrorType.fileNotFound:
        info = 'The update file could not be found.';
        icon = Icons.file_present;
        break;
      case UpdateErrorType.invalidVersion:
        info = 'The version information is invalid or corrupted.';
        icon = Icons.info;
        break;
      case UpdateErrorType.unknown:
      info = 'An unexpected error occurred.';
        icon = Icons.help_outline;
        break;
    }

    return Container(
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
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show the error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required UpdateErrorType errorType,
    VoidCallback? onRetry,
  }) {
    HapticFeedback.lightImpact();
    
    return showDialog<void>(
      context: context,
      builder: (context) => UpdateErrorDialog(
        title: title,
        message: message,
        errorType: errorType,
        onRetry: onRetry,
      ),
    );
  }
}