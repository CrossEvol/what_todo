import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/update/update_bloc.dart';
import '../models/update_models.dart';

/// Progress bar widget for displaying download progress on home page
class UpdateProgressBar extends StatelessWidget {
  final VersionInfo versionInfo;
  final DownloadProgress progress;
  final DateTime startTime;
  final bool showDetails;

  const UpdateProgressBar({
    Key? key,
    required this.versionInfo,
    required this.progress,
    required this.startTime,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildProgressIndicator(context),
          if (showDetails) ...[
            const SizedBox(height: 12),
            _buildProgressDetails(context),
          ],
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getStatusIcon(),
          color: _getStatusColor(context),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Updating to ${versionInfo.version}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
        ),
        Text(
          '${progress.progressPercentage}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.progress,
        minHeight: 8,
        backgroundColor: Theme.of(context).dividerColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getProgressColor(context),
        ),
      ),
    );
  }

  Widget _buildProgressDetails(BuildContext context) {
    final elapsed = DateTime.now().difference(startTime);
    final speed = progress.getFormattedSpeed(elapsed);
    final estimatedTime = _getEstimatedTimeRemaining(elapsed);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(context, 'Downloaded', progress.formattedSize),
            _buildDetailItem(context, 'Speed', speed),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(context, 'File', versionInfo.fileName),
            _buildDetailItem(context, 'ETA', estimatedTime),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (progress.status == DownloadStatus.downloading) ...[
          TextButton.icon(
            onPressed: () {
              context.read<UpdateBloc>().add(PauseResumeDownloadEvent(progress.taskId));
            },
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pause'),
          ),
          const SizedBox(width: 8),
        ] else if (progress.status == DownloadStatus.paused) ...[
          TextButton.icon(
            onPressed: () {
              context.read<UpdateBloc>().add(PauseResumeDownloadEvent(progress.taskId));
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Resume'),
          ),
          const SizedBox(width: 8),
        ] else if (progress.status == DownloadStatus.failed) ...[
          TextButton.icon(
            onPressed: () {
              context.read<UpdateBloc>().add(StartDownloadEvent(versionInfo));
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
          const SizedBox(width: 8),
        ],
        TextButton.icon(
          onPressed: () {
            context.read<UpdateBloc>().add(CancelDownloadEvent(progress.taskId));
          },
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (progress.status) {
      case DownloadStatus.pending:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.cancelled:
        return Icons.cancel;
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

  String _getStatusText() {
    switch (progress.status) {
      case DownloadStatus.pending:
        return 'Preparing download...';
      case DownloadStatus.downloading:
        return 'Downloading update...';
      case DownloadStatus.paused:
        return 'Download paused';
      case DownloadStatus.completed:
        return 'Download completed';
      case DownloadStatus.failed:
        return 'Download failed';
      case DownloadStatus.cancelled:
        return 'Download canceled';
    }
  }

  String _getEstimatedTimeRemaining(Duration elapsed) {
    if (progress.status != DownloadStatus.downloading || elapsed.inSeconds == 0 || progress.progress == 0) {
      return 'Calculating...';
    }

    final totalSeconds = elapsed.inSeconds / progress.progress;
    final remainingSeconds = totalSeconds - elapsed.inSeconds;

    if (remainingSeconds < 60) return '${remainingSeconds.round()}s';
    if (remainingSeconds < 3600) return '${(remainingSeconds / 60).round()}m';
    return '${(remainingSeconds / 3600).round()}h';
  }
}

/// Compact progress indicator for notifications or small spaces
class CompactUpdateProgress extends StatelessWidget {
  final DownloadProgress progress;
  final bool showPercentage;

  const CompactUpdateProgress({
    Key? key,
    required this.progress,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress.progress,
              strokeWidth: 2,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (showPercentage)
            Text(
              '${progress.progressPercentage}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          if (!showPercentage)
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
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

  String _getStatusText() {
    switch (progress.status) {
      case DownloadStatus.pending:
        return 'Preparing...';
      case DownloadStatus.downloading:
        return 'Downloading...';
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
}

/// Floating update notification widget
class UpdateNotificationBanner extends StatelessWidget {
  final VersionInfo versionInfo;
  final String currentVersion;
  final VoidCallback? onDismiss;

  const UpdateNotificationBanner({
    Key? key,
    required this.versionInfo,
    required this.currentVersion,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<UpdateBloc>().add(StartDownloadEvent(versionInfo));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.system_update,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Available',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Version ${versionInfo.version} (${versionInfo.formattedFileSize})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDismiss != null)
                      IconButton(
                        onPressed: onDismiss,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<UpdateBloc>().add(SkipVersionEvent(versionInfo.version));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<UpdateBloc>().add(StartDownloadEvent(versionInfo));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Update Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status widget for showing current update state
class UpdateStatusWidget extends StatelessWidget {
  final UpdateState state;

  const UpdateStatusWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is UpdateChecking) {
      return _buildCheckingWidget(context, state as UpdateChecking);
    } else if (state is UpdateAvailable) {
      return _buildAvailableWidget(context, state as UpdateAvailable);
    } else if (state is UpdateDownloading) {
      return _buildDownloadingWidget(context, state as UpdateDownloading);
    } else if (state is UpdateDownloaded) {
      return _buildDownloadedWidget(context, state as UpdateDownloaded);
    } else if (state is UpdateError) {
      return _buildErrorWidget(context, state as UpdateError);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCheckingWidget(BuildContext context, UpdateChecking state) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            state.isManual ? 'Checking for updates...' : 'Auto-checking for updates...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableWidget(BuildContext context, UpdateAvailable state) {
    return UpdateNotificationBanner(
      versionInfo: state.versionInfo,
      currentVersion: state.currentVersion,
      onDismiss: () {
        context.read<UpdateBloc>().add(const DismissUpdateEvent());
      },
    );
  }

  Widget _buildDownloadingWidget(BuildContext context, UpdateDownloading state) {
    return UpdateProgressBar(
      versionInfo: state.versionInfo,
      progress: state.progress,
      startTime: state.startTime,
    );
  }

  Widget _buildDownloadedWidget(BuildContext context, UpdateDownloaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Downloaded',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Version ${state.versionInfo.version} is ready to install',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<UpdateBloc>().add(const DismissUpdateEvent());
                  },
                  child: const Text('Later'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<UpdateBloc>().add(InstallUpdateEvent(state.filePath));
                  },
                  icon: const Icon(Icons.install_mobile, size: 16),
                  label: const Text('Install Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, UpdateError state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Error',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<UpdateBloc>().add(const DismissUpdateEvent());
                  },
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<UpdateBloc>().add(const RetryUpdateEvent());
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}