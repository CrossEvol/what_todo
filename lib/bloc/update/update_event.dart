part of 'update_bloc.dart';

abstract class UpdateEvent extends Equatable {
  const UpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check for available updates
class CheckForUpdatesEvent extends UpdateEvent {
  final bool isManual;

  const CheckForUpdatesEvent({this.isManual = false});

  @override
  List<Object?> get props => [isManual];
}

/// Event to start downloading an update
class StartDownloadEvent extends UpdateEvent {
  final VersionInfo versionInfo;

  const StartDownloadEvent(this.versionInfo);

  @override
  List<Object?> get props => [versionInfo];
}

/// Event to pause/resume download
class PauseResumeDownloadEvent extends UpdateEvent {
  final String taskId;

  const PauseResumeDownloadEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event to cancel download
class CancelDownloadEvent extends UpdateEvent {
  final String taskId;

  const CancelDownloadEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event for download progress updates
class DownloadProgressEvent extends UpdateEvent {
  final DownloadProgress progress;

  const DownloadProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Event to install downloaded update
class InstallUpdateEvent extends UpdateEvent {
  final String filePath;

  const InstallUpdateEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Event to skip a version
class SkipVersionEvent extends UpdateEvent {
  final String version;

  const SkipVersionEvent(this.version);

  @override
  List<Object?> get props => [version];
}

/// Event to update preferences
class UpdatePreferencesEvent extends UpdateEvent {
  final UpdatePreferences preferences;

  const UpdatePreferencesEvent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Event to dismiss update notification
class DismissUpdateEvent extends UpdateEvent {
  const DismissUpdateEvent();
}

/// Event to retry failed operation
class RetryUpdateEvent extends UpdateEvent {
  const RetryUpdateEvent();
}

/// Event to clear update state
class ClearUpdateStateEvent extends UpdateEvent {
  const ClearUpdateStateEvent();
}