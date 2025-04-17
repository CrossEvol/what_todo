import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'export_event.dart';
part 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  final TaskDB _taskDB;

  ExportBloc(this._projectDB, this._labelDB, this._taskDB)
      : super(ExportInitial()) {
    on<LoadExportDataEvent>(_loadExportData);
    on<DeleteProjectEvent>(_deleteProject);
    on<DeleteLabelEvent>(_deleteLabel);
    on<DeleteTaskEvent>(_deleteTask);
    on<ExportDataEvent>(_exportData);
    on<ChangeTabEvent>(_changeTab);
    on<ResetExportDataEvent>(_resetExportData);
  }

  FutureOr<void> _loadExportData(
      LoadExportDataEvent event, Emitter<ExportState> emit) async {
    emit(ExportLoading());
    try {
      final projects = await _projectDB.getProjectsWithCount();
      final labels = await _labelDB.getLabelsWithCount();
      final tasks = await _taskDB.getTasks();

      emit(ExportLoaded(
        projects: projects,
        labels: labels,
        tasks: tasks,
        currentTab: ExportTab.tasks,
      ));
    } catch (e) {
      logger.error("Error loading export data: $e");
      emit(ExportError("Failed to load export data"));
    }
  }

  FutureOr<void> _deleteProject(
      DeleteProjectEvent event, Emitter<ExportState> emit) async {
    if (state is ExportLoaded) {
      final currentState = state as ExportLoaded;
      final updatedProjects = currentState.projects!
          .where((project) => project.id != event.projectId)
          .toList();

      List<Task> updatedTasks = List.from(currentState.tasks!);
      if (event.deleteRelatedTasks) {
        // Remove all tasks related to this project
        updatedTasks = updatedTasks
            .where((task) => task.projectId != event.projectId)
            .toList();
      } else {
        // Only update project reference to Inbox (ID 1)
        updatedTasks = updatedTasks.map((task) {
          if (task.projectId == event.projectId) {
            task.projectId = 1; // Inbox project ID
            task.projectName = "Inbox";
          }
          return task;
        }).toList();
      }

      emit(currentState.copyWith(
        projects: updatedProjects,
        tasks: updatedTasks,
      ));
    }
  }

  FutureOr<void> _deleteLabel(
      DeleteLabelEvent event, Emitter<ExportState> emit) async {
    if (state is ExportLoaded) {
      final currentState = state as ExportLoaded;
      final updatedLabels = currentState.labels!
          .where((label) => label.id != event.labelId)
          .toList();

      List<Task> updatedTasks = List.from(currentState.tasks!);
      if (event.deleteRelatedTasks) {
        // Remove all tasks with this label
        final tasksToRemove = updatedTasks
            .where((task) =>
                task.labelList.any((label) => label.id == event.labelId))
            .toList();
        updatedTasks.removeWhere((task) => tasksToRemove.contains(task));
      } else {
        // Only remove the label from tasks
        updatedTasks = updatedTasks.map((task) {
          task.labelList.removeWhere((label) => label.id == event.labelId);
          return task;
        }).toList();
      }

      emit(currentState.copyWith(
        labels: updatedLabels,
        tasks: updatedTasks,
      ));
    }
  }

  FutureOr<void> _deleteTask(
      DeleteTaskEvent event, Emitter<ExportState> emit) async {
    if (state is ExportLoaded) {
      final currentState = state as ExportLoaded;
      final updatedTasks =
          currentState.tasks!.where((task) => task.id != event.taskId).toList();

      emit(currentState.copyWith(tasks: updatedTasks));
    }
  }

  FutureOr<void> _exportData(
      ExportDataEvent event, Emitter<ExportState> emit) async {
    if (state is ExportLoaded) {
      final currentState = state as ExportLoaded;
      try {
        // Construct exportable data using the data in the current state
        final exportData = {
          '__v': 1,
          'projects': currentState.projects!.map((p) => p.toMap()).toList(),
          'labels': currentState.labels!.map((l) => l.toMap()).toList(),
          'tasks': currentState.tasks!.map((t) {
            return {
              'id': t.id,
              'title': t.title,
              'comment': t.comment,
              'dueDate': DateTime.fromMillisecondsSinceEpoch(t.dueDate)
                  .toIso8601String(),
              'priority': t.priority.index,
              'status': t.tasksStatus?.index ?? 0,
              'projectName': t.projectName ?? 'Inbox',
              'order': t.order,
              'labelNames': t.labelList.map((l) => l.name).toList(),
            };
          }).toList(),
        };

        emit(ExportSuccess(
            exportData: exportData,
            useNewFormat: event.useNewFormat,
            projects: currentState.projects,
            labels: currentState.labels,
            tasks: currentState.tasks,
            currentTab: currentState.currentTab));
      } catch (e) {
        logger.error("Error exporting data: $e");
        emit(ExportError("Failed to export data"));
      }
    }
  }

  FutureOr<void> _changeTab(ChangeTabEvent event, Emitter<ExportState> emit) {
    if (state is ExportLoaded) {
      final currentState = state as ExportLoaded;
      emit(currentState.copyWith(currentTab: event.tab));
    }
  }

  FutureOr<void> _resetExportData(ResetExportDataEvent event, Emitter<ExportState> emit) {
    emit(ExportInitial());
  }
}
