part of 'export_bloc.dart';

enum ExportTab { projects, labels, tasks }

abstract class ExportState extends Equatable {
  final List<ProjectWithCount>? projects;
  final List<LabelWithCount>? labels;
  final List<Task>? tasks;
  final List<ResourceModel>? resources;
  final ExportTab? currentTab;

  const ExportState({
    this.projects,
    this.labels,
    this.tasks,
    this.resources,
    this.currentTab,
  });

  @override
  List<Object?> get props => [projects, labels, tasks, resources, currentTab];
}

class ExportInitial extends ExportState {
  ExportInitial() : super();
}

class ExportLoading extends ExportState {
  ExportLoading() : super();
}

class ExportLoaded extends ExportState {
  const ExportLoaded({
    required List<ProjectWithCount> projects,
    required List<LabelWithCount> labels,
    required List<Task> tasks,
    required List<ResourceModel> resources,
    required ExportTab currentTab,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          resources: resources,
          currentTab: currentTab,
        );

  ExportLoaded copyWith({
    List<ProjectWithCount>? projects,
    List<LabelWithCount>? labels,
    List<Task>? tasks,
    List<ResourceModel>? resources,
    ExportTab? currentTab,
  }) {
    return ExportLoaded(
      projects: projects ?? this.projects!,
      labels: labels ?? this.labels!,
      tasks: tasks ?? this.tasks!,
      resources: resources ?? this.resources!,
      currentTab: currentTab ?? this.currentTab!,
    );
  }
}

class ExportError extends ExportState {
  final String message;

  const ExportError(this.message) : super();

  @override
  List<Object?> get props => [message, ...super.props];
}

class ExportSuccess extends ExportState {
  final Map<String, dynamic> exportData;
  final bool useNewFormat;

  const ExportSuccess({
    required this.exportData,
    required this.useNewFormat,
    List<ProjectWithCount>? projects,
    List<LabelWithCount>? labels,
    List<Task>? tasks,
    List<ResourceModel>? resources,
    ExportTab? currentTab,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          resources: resources,
          currentTab: currentTab,
        );

  @override
  List<Object?> get props => [exportData, useNewFormat, ...super.props];
}

class ExportToGitHubSuccess extends ExportState {
  const ExportToGitHubSuccess({
    List<ProjectWithCount>? projects,
    List<LabelWithCount>? labels,
    List<Task>? tasks,
    List<ResourceModel>? resources,
    ExportTab? currentTab,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          resources: resources,
          currentTab: currentTab,
        );
}
