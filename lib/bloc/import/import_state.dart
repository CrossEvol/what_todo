part of 'import_bloc.dart';

enum ImportTab { tasks, projects, labels }

// States
abstract class ImportState extends Equatable {
  final List<ProjectWithCount> projects;
  final List<LabelWithCount> labels;
  final List<Task> tasks;
  final ImportTab currentTab;

  const ImportState({
    required this.projects,
    required this.labels,
    required this.tasks,
    required this.currentTab,
  });

  @override
  List<Object> get props => [projects, labels, tasks, currentTab];
}

class ImportInitial extends ImportState {
  ImportInitial()
      : super(
          projects: [],
          labels: [],
          tasks: [],
          currentTab: ImportTab.tasks,
        );
}

class ImportLoading extends ImportState {
  ImportLoading()
      : super(
          projects: [],
          labels: [],
          tasks: [],
          currentTab: ImportTab.tasks,
        );
}

class ImportLoaded extends ImportState {
  const ImportLoaded({
    required List<ProjectWithCount> projects,
    required List<LabelWithCount> labels,
    required List<Task> tasks,
    required ImportTab currentTab,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          currentTab: currentTab,
        );

  ImportLoaded copyWith({
    List<ProjectWithCount>? projects,
    List<LabelWithCount>? labels,
    List<Task>? tasks,
    ImportTab? currentTab,
  }) {
    return ImportLoaded(
      projects: projects ?? this.projects,
      labels: labels ?? this.labels,
      tasks: tasks ?? this.tasks,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class ImportConfirmed extends ImportState {
  const ImportConfirmed({
    required List<ProjectWithCount> projects,
    required List<LabelWithCount> labels,
    required List<Task> tasks,
  }) : super(
    projects: projects,
    labels: labels,
    tasks: tasks,
    currentTab: ImportTab.tasks,
  );
}


class ImportInProgress extends ImportState {
  const ImportInProgress({
    required List<ProjectWithCount> projects,
    required List<LabelWithCount> labels,
    required List<Task> tasks,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          currentTab: ImportTab.tasks,
        );
}

class ImportSuccess extends ImportState {
  const ImportSuccess()
      : super(
          projects: const [],
          labels: const [],
          tasks: const [],
          currentTab: ImportTab.tasks,
        );
}

class ImportError extends ImportState {
  final String message;

  const ImportError({
    required this.message,
    required List<ProjectWithCount> projects,
    required List<LabelWithCount> labels,
    required List<Task> tasks,
    required ImportTab currentTab,
  }) : super(
          projects: projects,
          labels: labels,
          tasks: tasks,
          currentTab: currentTab,
        );

  @override
  List<Object> get props => [message, projects, labels, tasks, currentTab];
}
