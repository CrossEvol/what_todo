import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'import_event.dart';

part 'import_state.dart';

// Bloc
class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  final TaskDB _taskDB;

  ImportBloc(this._projectDB, this._labelDB, this._taskDB)
      : super(ImportInitial()) {
    on<ImportLoadDataEvent>(_onImportLoadData);
    on<ChangeImportTabEvent>(_onChangeTab);
    on<DeleteProjectEvent>(_onDeleteProject);
    on<DeleteLabelEvent>(_onDeleteLabel);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ConfirmImportEvent>(_onConfirmImport);
    on<ImportInProgressEvent>(_onImportInProgress);
  }

  FutureOr<void> _onImportLoadData(
      ImportLoadDataEvent event, Emitter<ImportState> emit) async {
    emit(ImportLoading());

    try {
      final data = event.importData;

      // Parse and process imported data
      List<ProjectWithCount> projects = [];
      List<LabelWithCount> labels = [];
      List<Task> tasks = [];

      // Check if it's v1 format (has __v key)
      bool isV1Format = data is Map && data.containsKey('__v');

      if (isV1Format) {
        // Process v1 format
        if (data.containsKey('projects')) {
          final projectMaps =
              (data['projects'] as List).cast<Map<String, dynamic>>();
          for (var projectMap in projectMaps) {
            final project = Project.fromMap(projectMap);
            // Count tasks for this project
            int count = 0;
            if (data.containsKey('tasks')) {
              final taskList =
                  (data['tasks'] as List).cast<Map<String, dynamic>>();
              count = taskList
                  .where((task) => task['projectName'] == project.name)
                  .length;
            }
            projects.add(ProjectWithCount.fromMap({
              ...projectMap,
              'count': count,
            }));
          }
        }

        if (data.containsKey('labels')) {
          final labelMaps =
              (data['labels'] as List).cast<Map<String, dynamic>>();
          for (var labelMap in labelMaps) {
            final label = Label.fromMap(labelMap);
            // Count tasks for this label
            int count = 0;
            if (data.containsKey('tasks')) {
              final taskList =
                  (data['tasks'] as List).cast<Map<String, dynamic>>();
              count = taskList
                  .where((task) =>
                      (task['labelNames'] as List?)?.contains(label.name) ??
                      false)
                  .length;
            }
            labels.add(LabelWithCount.fromMap({
              ...labelMap,
              'count': count,
            }));
          }
        }

        if (data.containsKey('tasks')) {
          final taskMaps = (data['tasks'] as List).cast<Map<String, dynamic>>();
          for (var taskMap in taskMaps) {
            final task = Task.fromImport(taskMap);
            task.projectName = taskMap['projectName'] as String? ?? 'Inbox';

            // Fix for label list
            List<String> labelNames = [];
            if (taskMap.containsKey('labelNames') &&
                taskMap['labelNames'] != null) {
              labelNames = (taskMap['labelNames'] as List)
                  .map((name) => name.toString())
                  .toList();
            }

            task.labelList = [];
            for (var labelName in labelNames) {
              // Create a Label using the static name and default values
              task.labelList.add(Label.fromMap({
                'name': labelName,
                'colorCode': 0xFF9E9E9E, // Default gray color
                'colorName': 'Grey',
              }));
            }

            tasks.add(task);
          }
        }
      } else {
        // Handle legacy format (v0)
        List<dynamic> taskJsonList = data is List ? data : [data];
        Set<String> projectNames = {};

        for (var task in taskJsonList) {
          if (task is Map<String, dynamic>) {
            projectNames.add(task['projectName'] as String? ?? 'Inbox');

            final importedTask = Task.fromImport(task);
            importedTask.projectName =
                task['projectName'] as String? ?? 'Inbox';
            tasks.add(importedTask);
          }
        }

        // Create projects from names
        for (var projectName in projectNames) {
          final count =
              tasks.where((task) => task.projectName == projectName).length;
          final project = Project.byName(projectName);
          projects.add(ProjectWithCount(
            id: project.id ?? 0,
            name: project.name,
            colorCode: project.colorValue,
            colorName: project.colorName,
            count: count,
          ));
        }
      }

      emit(ImportLoaded(
        projects: projects,
        labels: labels,
        tasks: tasks,
        currentTab: ImportTab.tasks,
      ));
    } catch (e) {
      emit(ImportError(
        message: 'Error loading import data: $e',
        projects: [],
        labels: [],
        tasks: [],
        currentTab: ImportTab.tasks,
      ));
    }
  }

  FutureOr<void> _onChangeTab(
      ChangeImportTabEvent event, Emitter<ImportState> emit) {
    if (state is ImportLoaded) {
      final currentState = state as ImportLoaded;
      emit(currentState.copyWith(currentTab: event.tab));
    }
  }

  FutureOr<void> _onDeleteProject(
      DeleteProjectEvent event, Emitter<ImportState> emit) {
    if (state is ImportLoaded) {
      final currentState = state as ImportLoaded;
      final projects = List<ProjectWithCount>.from(currentState.projects);
      final projectToRemove = projects[event.projectIndex];
      projects.removeAt(event.projectIndex);

      List<Task> updatedTasks = List<Task>.from(currentState.tasks);

      if (event.deleteRelatedTasks) {
        // Remove all tasks associated with this project
        updatedTasks
            .removeWhere((task) => task.projectName == projectToRemove.name);
      } else {
        // Move tasks to Inbox
        for (var i = 0; i < updatedTasks.length; i++) {
          if (updatedTasks[i].projectName == projectToRemove.name) {
            final task = updatedTasks[i];
            task.projectName = 'Inbox';
            task.projectId = 1; // Assume Inbox is ID 1
            updatedTasks[i] = task;
          }
        }
      }

      emit(currentState.copyWith(
        projects: projects,
        tasks: updatedTasks,
      ));
    }
  }

  FutureOr<void> _onDeleteLabel(
      DeleteLabelEvent event, Emitter<ImportState> emit) {
    if (state is ImportLoaded) {
      final currentState = state as ImportLoaded;
      final labels = List<LabelWithCount>.from(currentState.labels);
      final labelToRemove = labels[event.labelIndex];
      labels.removeAt(event.labelIndex);

      List<Task> updatedTasks = List<Task>.from(currentState.tasks);

      // Remove the label from all tasks
      for (var i = 0; i < updatedTasks.length; i++) {
        var task = updatedTasks[i];
        task.labelList.removeWhere((label) => label.name == labelToRemove.name);
        updatedTasks[i] = task;
      }

      emit(currentState.copyWith(
        labels: labels,
        tasks: updatedTasks,
      ));
    }
  }

  FutureOr<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<ImportState> emit) {
    if (state is ImportLoaded) {
      final currentState = state as ImportLoaded;
      final tasks = List<Task>.from(currentState.tasks);
      tasks.removeAt(event.taskIndex);

      emit(currentState.copyWith(tasks: tasks));
    }
  }

  FutureOr<void> _onConfirmImport(
      ConfirmImportEvent event, Emitter<ImportState> emit) async {
    if (state is ImportLoaded) {
      final currentState = state as ImportLoaded;

      // Emit ImportInProgress before starting the import process
      emit(ImportConfirmed(
        projects: currentState.projects,
        labels: currentState.labels,
        tasks: currentState.tasks,
      ));
    }
  }

  FutureOr<void> _onImportInProgress(
      ImportInProgressEvent event, Emitter<ImportState> emit) async {
    try {
      // Import projects
      for (var project in event.projects) {
        final projectObj = Project(
            id: project.id,
            name: project.name,
            colorValue: project.colorCode,
            colorName: project.colorName);

        if (!await _projectDB.isProjectExists(projectObj)) {
          await _projectDB.insertProject(projectObj);
        }
      }

      // Import labels
      for (var label in event.labels) {
        final labelObj = Label.fromMap({
          'id': label.id,
          'name': label.name,
          'colorCode': label.colorCode,
          'colorName': label.colorName,
        });

        if (!await _labelDB.isLabelExists(labelObj)) {
          await _labelDB.insertLabel(labelObj);
        }
      }

      // Import tasks
      for (var task in event.tasks) {
        // Find project ID for the task
        int projectId = 1; // Default to Inbox
        for (var project in event.projects) {
          if (project.name == task.projectName) {
            projectId = project.id;
            break;
          }
        }
        task.projectId = projectId;

        // Find label IDs for the task
        List<int> labelIds = [];
        for (var taskLabel in task.labelList) {
          for (var label in event.labels) {
            if (label.name == taskLabel.name) {
              labelIds.add(label.id);
              break;
            }
          }
        }

        // Create or update the task
        await _taskDB.createTask(task, labelIDs: labelIds);
      }

      emit(const ImportSuccess());
    } catch (e) {
      emit(ImportError(
        message: 'Error during import: $e',
        projects: event.projects,
        labels: event.labels,
        tasks: event.tasks,
        currentTab: ImportTab.tasks,
      ));
    }
  }
}
