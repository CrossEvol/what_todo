import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/update/update_bloc.dart';
import '../../models/update_models.dart';
import '../../utils/logger_util.dart';

class UpdateManagerPage extends StatefulWidget {
  const UpdateManagerPage({super.key});

  @override
  State<UpdateManagerPage> createState() => _UpdateManagerPageState();
}

class _UpdateManagerPageState extends State<UpdateManagerPage> {
  DownloadOption _selectedOption = DownloadOption.official;
  String _statusText = 'Ready';
  String _progressText = 'Not started';
  DownloadProgress? _currentProgress;
  VersionInfo? _currentVersionInfo;
  List<String> _logMessages = [];
  bool _isCheckingUpdates = false;

  @override
  void initState() {
    super.initState();
    _addLogMessage('Update Manager initialized');
  }

  void _addLogMessage(String message) {
    setState(() {
      _logMessages
          .add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    logger.info('UpdateManagerPage: $message');
  }

  void _checkForUpdates() {
    if (_selectedOption.requiresVersionCheck) {
      _addLogMessage('Checking for updates...');
      setState(() {
        _isCheckingUpdates = true;
      });
      context
          .read<UpdateBloc>()
          .add(const CheckForUpdatesEvent(isManual: true));
    }
  }

  void _startDownload() {
    // Removed the specific logic for DownloadOption.testAPK
    if (_currentVersionInfo != null) {
      _addLogMessage('Starting download: ${_currentVersionInfo!.fileName}');
      context.read<UpdateBloc>().add(StartDownloadEvent(_currentVersionInfo!));
    } else {
      _addLogMessage(
          'No version info available for download. Please check for updates first.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No version info available. Check for updates.')),
      );
    }
  }

  void _pauseResumeDownload() {
    if (_currentProgress?.taskId != null) {
      final action = _currentProgress!.status == DownloadStatus.downloading
          ? 'Pausing'
          : 'Resuming';
      _addLogMessage('$action download...');
      context
          .read<UpdateBloc>()
          .add(PauseResumeDownloadEvent(_currentProgress!.taskId));
    }
  }

  void _cancelDownload() {
    if (_currentProgress?.taskId != null) {
      _addLogMessage('Cancelling download...');
      context
          .read<UpdateBloc>()
          .add(CancelDownloadEvent(_currentProgress!.taskId));
    }
  }

  void _installUpdate(String filePath) {
    if (_currentVersionInfo != null) {
      _addLogMessage('Starting installation...');
      context.read<UpdateBloc>().add(InstallUpdateEvent(filePath));
    }
  }

  // Button state management methods
  bool _canCheckUpdates(UpdateState state) {
    return !_isCheckingUpdates &&
        !(state is UpdateDownloading) &&
        !(state is UpdateInstalling);
  }

  bool _canStartDownload(UpdateState state) {
    if (state is UpdateDownloading || state is UpdateInstalling) {
      return false;
    }
    return _currentVersionInfo != null;
  }

  bool _showPauseResumeButton(UpdateState state) {
    return state is UpdateDownloading || state is UpdateDownloadPaused;
  }

  bool _showCancelButton(UpdateState state) {
    return state is UpdateDownloading || state is UpdateDownloadPaused;
  }

  IconData _getStatusIcon() {
    if (_isCheckingUpdates) return Icons.refresh;
    if (_currentProgress != null) {
      switch (_currentProgress!.status) {
        case DownloadStatus.downloading:
          return Icons.download;
        case DownloadStatus.paused:
          return Icons.pause;
        case DownloadStatus.completed:
          return Icons.check_circle;
        case DownloadStatus.failed:
          return Icons.error;
        case DownloadStatus.cancelled:
          return Icons.cancel;
        default:
          return Icons.info;
      }
    }
    return Icons.info;
  }

  Color _getStatusColor() {
    if (_isCheckingUpdates) return Colors.blue;
    if (_currentProgress != null) {
      switch (_currentProgress!.status) {
        case DownloadStatus.downloading:
          return Colors.green;
        case DownloadStatus.paused:
          return Colors.orange;
        case DownloadStatus.completed:
          return Colors.green;
        case DownloadStatus.failed:
          return Colors.red;
        case DownloadStatus.cancelled:
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<UpdateBloc, UpdateState>(
        listener: _handleUpdateStateChanges,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildDownloadOptionsSection(), // REMOVE or comment out this line
                // const SizedBox(height: 24), // REMOVE or comment out this line
                _buildControlButtonsSection(),
                const SizedBox(height: 24),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildLogsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controls',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<UpdateBloc, UpdateState>(
          builder: (context, state) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _canCheckUpdates(state) ? _checkForUpdates : null,
                  icon: _isCheckingUpdates
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                      _isCheckingUpdates ? 'Checking...' : 'Check for Updates'),
                ),

                // Start Download Button
                ElevatedButton.icon(
                  onPressed: _canStartDownload(state) ? _startDownload : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Start Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),

                // Pause/Resume Button
                if (_showPauseResumeButton(state))
                  ElevatedButton.icon(
                    onPressed: _pauseResumeDownload,
                    icon: Icon(
                      state is UpdateDownloading
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      state is UpdateDownloading ? 'Pause' : 'Resume',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // Cancel Button
                if (_showCancelButton(state))
                  ElevatedButton.icon(
                    onPressed: _cancelDownload,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // Install Button
                if (state is UpdateDownloaded)
                  ElevatedButton.icon(
                    onPressed: () => _installUpdate(state.filePath),
                    icon: const Icon(Icons.install_mobile),
                    label: const Text('Install'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: $_statusText',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Progress: $_progressText',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Show progress bar for active downloads
              if (_currentProgress != null &&
                  _currentProgress!.status == DownloadStatus.downloading)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _currentProgress!.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentProgress!.formattedSize,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _currentProgress!.formattedSpeed,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Show version info if available
              if (_currentVersionInfo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version: ${_currentVersionInfo!.version}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          'File: ${_currentVersionInfo!.fileName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (_currentVersionInfo!.fileSize != null)
                          Text(
                            'Size: ${_currentVersionInfo!.formattedFileSize}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            reverse: true,
            itemCount: _logMessages.length,
            itemBuilder: (context, index) {
              final reversedIndex = _logMessages.length - 1 - index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  _logMessages[reversedIndex],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleUpdateStateChanges(BuildContext context, UpdateState state) {
    setState(() {
      _isCheckingUpdates = false;

      if (state is UpdateChecking) {
        _statusText = 'Checking for updates...';
        _isCheckingUpdates = true;
        _addLogMessage('Checking for updates...');
      } else if (state is UpdateAvailable) {
        _statusText = 'Update available: ${state.versionInfo.version}';
        _currentVersionInfo = state.versionInfo;
        _addLogMessage('Update available: ${state.versionInfo.version}');
      } else if (state is UpdateNotAvailable) {
        _statusText = 'No new updates available';
        _currentVersionInfo = null;
        _addLogMessage('No new updates available');
      } else if (state is UpdateDownloading) {
        _statusText = 'Downloading...';
        _progressText =
            '${(state.progress.percentageComplete).toStringAsFixed(1)}%';
        _currentProgress = state.progress;
        _currentVersionInfo = state.versionInfo;
        _addLogMessage('Download progress: ${_progressText}');
      } else if (state is UpdateDownloadPaused) {
        _statusText = 'Download Paused';
        _currentProgress = state.progress;
        _currentVersionInfo = state.versionInfo;
        _addLogMessage('Download paused');
      } else if (state is UpdateDownloaded) {
        _statusText = 'Download Complete! Ready to install';
        _progressText = '100% - File: ${state.filePath}';
        _currentVersionInfo = state.versionInfo;
        _addLogMessage('Download completed: ${state.filePath}');
      } else if (state is UpdateInstalling) {
        _statusText = 'Installing...';
        _addLogMessage('Installing update...');
      } else if (state is UpdateInstallationCompleted) {
        _statusText = 'Installation completed';
        _addLogMessage('Installation completed successfully');
      } else if (state is UpdateError) {
        _statusText = 'Error: ${state.message}';
        _progressText = 'Failed';
        _addLogMessage('Error: ${state.message}');
      }
    });
  }
}
