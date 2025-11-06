import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_app/models/task_label_relation.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/dao/resource_db.dart';
import 'package:flutter_app/models/resource.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'import_event.dart';

part 'import_state.dart';

// Bloc
class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  final TaskDB _taskDB;
  final ResourceDB _resourceDB;

  ImportBloc(this._projectDB, this._labelDB, this._taskDB, this._resourceDB)
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
      List<ResourceModel> resources = [];

      // Check if it's new format (has __v key)
      bool isNewFormat = data is Map && data.containsKey('__v');
      int formatVersion = 1;
      
      if (isNewFormat) {
        formatVersion = data['__v'] as int? ?? 1;
      }

      if (isNewFormat) {
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

        // 处理资源数据（仅在 V2 格式中存在）
        if (formatVersion >= 2 && data.containsKey('resources')) {
          final resourceMaps = (data['resources'] as List).cast<Map<String, dynamic>>();
          for (var resourceMap in resourceMaps) {
            // 创建占位的 ResourceModel，taskId 设为 -1
            final resource = ResourceModel(
              id: resourceMap['id'] as int? ?? 0,
              path: resourceMap['path'] as String,
              taskId: -1, // 占位值
              createTime: DateTime.now(),
            );
            // 保存 task_title 用于后续映射
            resource.taskTitle = resourceMap['task_title'] as String?;
            resources.add(resource);
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
        resources: resources,
        currentTab: ImportTab.tasks,
      ));
    } catch (e) {
      emit(ImportError(
        message: 'Error loading import data: $e',
        projects: [],
        labels: [],
        tasks: [],
        resources: [],
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
        resources: currentState.resources,
      ));
    }
  }

  FutureOr<void> _onImportInProgress(
      ImportInProgressEvent event, Emitter<ImportState> emit) async {
    final startTime = DateTime.now();
    logger.info('Import started at: ${startTime.toIso8601String()}');
    logger.info('Import data: ${event.projects.length} projects, ${event.labels.length} labels, ${event.tasks.length} tasks, ${event.resources.length} resources');

    try {
      // Pre-filtering: Check existing records to avoid unnecessary operations
      final filterStartTime = DateTime.now();
      
      // Get existing project names
      final projectNames = event.projects.map((p) => p.name).toList();
      final existingProjectNames = await _projectDB.getExistingProjectNames(projectNames);
      
      // Filter out existing projects
      final newProjects = event.projects
          .where((project) => !existingProjectNames.contains(project.name))
          .map((project) => Project(
              id: project.id,
              name: project.name,
              colorValue: project.colorCode,
              colorName: project.colorName))
          .toList();

      // Get existing label names
      final labelNames = event.labels.map((l) => l.name).toList();
      final existingLabelNames = await _labelDB.getExistingLabelNames(labelNames);
      
      // Filter out existing labels
      final newLabels = event.labels
          .where((label) => !existingLabelNames.contains(label.name))
          .map((label) => Label.fromMap({
              'id': label.id,
              'name': label.name,
              'colorCode': label.colorCode,
              'colorName': label.colorName,
            }))
          .toList();

      // Get existing task titles
      final taskTitles = event.tasks.map((t) => t.title).toList();
      final existingTaskTitles = await _taskDB.getExistingTaskTitles(taskTitles);
      
      // Filter out existing tasks
      final newTasks = event.tasks
          .where((task) => !existingTaskTitles.contains(task.title))
          .toList();

      final filterDuration = DateTime.now().difference(filterStartTime);
      logger.info('Pre-filtering completed in ${filterDuration.inMilliseconds}ms');
      logger.info('Filtered data: ${newProjects.length} new projects, ${newLabels.length} new labels, ${newTasks.length} new tasks');

      // Batch import projects with error handling
      if (newProjects.isNotEmpty) {
        final projectStartTime = DateTime.now();
        try {
          await _projectDB.batchInsertProjects(newProjects);
          final projectDuration = DateTime.now().difference(projectStartTime);
          logger.info('Batch project import completed in ${projectDuration.inMilliseconds}ms');
        } catch (e) {
          logger.warn('Batch project import failed, falling back to individual inserts: $e');
          // Fallback to individual operations
          for (var project in newProjects) {
            try {
              await _projectDB.insertProject(project);
            } catch (individualError) {
              logger.error('Failed to insert project ${project.name}: $individualError');
            }
          }
        }
      }

      // Batch import labels with error handling
      if (newLabels.isNotEmpty) {
        final labelStartTime = DateTime.now();
        try {
          await _labelDB.batchInsertLabels(newLabels);
          final labelDuration = DateTime.now().difference(labelStartTime);
          logger.info('Batch label import completed in ${labelDuration.inMilliseconds}ms');
        } catch (e) {
          logger.warn('Batch label import failed, falling back to individual inserts: $e');
          // Fallback to individual operations
          for (var label in newLabels) {
            try {
              await _labelDB.insertLabel(label);
            } catch (individualError) {
              logger.error('Failed to insert label ${label.name}: $individualError');
            }
          }
        }
      }

      // Query database for actual IDs after insertion
      final mappingStartTime = DateTime.now();
      
      // Get actual project IDs from database
      final allProjectNames = event.projects.map((p) => p.name).toList();
      final actualProjects = await _projectDB.getProjectsByNames(allProjectNames);
      final projectNameToId = <String, int>{};
      for (var project in actualProjects) {
        projectNameToId[project.name] = project.id!;
      }

      // Get actual label IDs from database
      final allLabelNames = event.labels.map((l) => l.name).toList();
      final actualLabels = await _labelDB.getLabelsByNames(allLabelNames);
      final labelNameToId = <String, int>{};
      for (var label in actualLabels) {
        labelNameToId[label.name] = label.id!;
      }

      final mappingDuration = DateTime.now().difference(mappingStartTime);
      logger.info('ID mapping completed in ${mappingDuration.inMilliseconds}ms');

      // Batch import tasks and create task-label relationships with error handling
      if (newTasks.isNotEmpty) {
        final taskStartTime = DateTime.now();
        
        // Prepare tasks with correct project IDs from database
        for (var task in newTasks) {
          // Use actual project ID from database
          final projectId = projectNameToId[task.projectName] ?? 1; // Default to Inbox
          task.projectId = projectId;
        }

        try {
          // Batch insert tasks and get their IDs
          final insertedTaskIds = await _taskDB.batchInsertTasks(newTasks);
          final taskDuration = DateTime.now().difference(taskStartTime);
          logger.info('Batch task import completed in ${taskDuration.inMilliseconds}ms');

          // Create task-label relationships using actual database IDs
          final relationStartTime = DateTime.now();
          final taskLabelRelations = <TaskLabelRelation>[];
          
          for (int i = 0; i < newTasks.length; i++) {
            final task = newTasks[i];
            final taskId = insertedTaskIds[i];
            
            // Build relationships for this task's labels using actual database IDs
            for (var taskLabel in task.labelList) {
              final labelId = labelNameToId[taskLabel.name];
              if (labelId != null) {
                taskLabelRelations.add(TaskLabelRelation(
                  taskId: taskId,
                  labelId: labelId,
                ));
              }
            }
          }

          // Batch insert task-label relationships
          if (taskLabelRelations.isNotEmpty) {
            try {
              await _taskDB.batchInsertTaskLabels(taskLabelRelations);
              final relationDuration = DateTime.now().difference(relationStartTime);
              logger.info('Batch task-label relationship creation completed in ${relationDuration.inMilliseconds}ms');
            } catch (e) {
              logger.error('Batch task-label relationship creation failed: $e');
              // Note: Individual fallback for relationships would require more complex logic
              // as we'd need to recreate the relationships one by one
              throw e; // Re-throw to trigger overall fallback
            }
          }
        } catch (e) {
          logger.warn('Batch task import failed, falling back to individual inserts: $e');
          // Fallback to individual operations
          for (var task in newTasks) {
            try {
              // Use actual project ID from database
              final projectId = projectNameToId[task.projectName] ?? 1; // Default to Inbox
              task.projectId = projectId;

              // Find actual label IDs from database
              List<int> labelIds = [];
              for (var taskLabel in task.labelList) {
                final labelId = labelNameToId[taskLabel.name];
                if (labelId != null) {
                  labelIds.add(labelId);
                }
              }

              // Create task with relationships using actual database IDs
              await _taskDB.createTask(task, labelIDs: labelIds);
            } catch (individualError) {
              logger.error('Failed to insert task ${task.title}: $individualError');
            }
          }
        }
      }

      // 处理资源导入
      if (event.resources.isNotEmpty) {
        final resourceStartTime = DateTime.now();
        
        // 过滤掉重复的 path 信息
        final uniqueResources = <String, ResourceModel>{};
        for (final resource in event.resources) {
          uniqueResources[resource.path] = resource;
        }
        final filteredResources = uniqueResources.values.toList();
        
        // 批量插入资源，使用占位的 taskId (-1)
        try {
          await _resourceDB.batchInsertResources(filteredResources);
          
          // 获取实际的任务映射
          final allTaskTitles = event.tasks.map((t) => t.title).toList();
          final actualTasks = await _taskDB.getTasksByTitles(allTaskTitles);
          final taskTitleToId = <String, int>{};
          for (final task in actualTasks) {
            if (task.id != null) {
              taskTitleToId[task.title] = task.id!;
            }
          }
          
          // 更新资源的 taskId
          for (final resource in filteredResources) {
            if (resource.taskTitle != null) {
              final realTaskId = taskTitleToId[resource.taskTitle!];
              if (realTaskId != null) {
                await _resourceDB.updateResourceTaskId(resource.id, realTaskId);
              }
            }
          }
          
          // 异步复制资源文件
          _copyResourcesAsync(filteredResources, event.importPath);
          
          final resourceDuration = DateTime.now().difference(resourceStartTime);
          logger.info('Resource import completed in ${resourceDuration.inMilliseconds}ms');
        } catch (e) {
          logger.error('Resource import failed: $e');
          // 不抛出异常，让主导入流程继续
        }
      }

      final totalDuration = DateTime.now().difference(startTime);
      logger.info('Import completed successfully in ${totalDuration.inMilliseconds}ms');
      
      emit(const ImportSuccess());
    } catch (e) {
      final totalDuration = DateTime.now().difference(startTime);
      logger.error('Import failed after ${totalDuration.inMilliseconds}ms: $e');
      
      emit(ImportError(
        message: 'Error during import: $e',
        projects: event.projects,
        labels: event.labels,
        tasks: event.tasks,
        resources: event.resources,
        currentTab: ImportTab.tasks,
      ));
    }
  }



  void _copyResourcesAsync(List<ResourceModel> resources, String? importPath) {
    if (importPath == null) return;
    
    // 使用 Future 进行异步处理，避免阻塞
    Future.microtask(() async {
      try {
        final importDir = Directory(importPath).parent;
        final resourcesDir = Directory('${importDir.path}/resources');
        
        if (await resourcesDir.exists()) {
          for (final resource in resources) {
            final fileName = resource.path.split('/').last;
            final sourceFile = File('${resourcesDir.path}/$fileName');
            final destFile = File(resource.path);
            
            // 只有当目标图片资源不存在时才进行复制
            if (await sourceFile.exists() && !await destFile.exists()) {
              await sourceFile.copy(resource.path);
            }
          }
        }
      } catch (e) {
        logger.warn('Error copying resources: $e');
      }
    });
  }
}
