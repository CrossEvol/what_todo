import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/dao/resource_db.dart';
import 'package:flutter_app/models/resource.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'export_event.dart';
part 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  final TaskDB _taskDB;
  final ResourceDB _resourceDB;

  ExportBloc(this._projectDB, this._labelDB, this._taskDB, this._resourceDB)
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
      
      // 收集所有资源信息
      List<ResourceModel> resources = [];
      for (final task in tasks) {
        if (task.id != null) {
          final taskResources = await _resourceDB.getResourcesByTaskId(task.id!);
          resources.addAll(taskResources);
        }
      }

      emit(ExportLoaded(
        projects: projects,
        labels: labels,
        tasks: tasks,
        resources: resources,
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
        // 创建任务ID到任务标题的映射
        final taskIdToTitle = <int, String>{};
        for (final task in currentState.tasks!) {
          if (task.id != null) {
            taskIdToTitle[task.id!] = task.title;
          }
        }

        // 转换资源数据，读取图片并编码为 base64
        final resourcesData = <Map<String, dynamic>>[];
        for (final resource in currentState.resources!) {
          try {
            // 读取图片文件
            final file = File(resource.path);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64Content = base64.encode(bytes);
              
              final taskTitle = resource.taskId != null 
                  ? taskIdToTitle[resource.taskId!] 
                  : null;
              
              // 只导出 content 和 task_title 两个字段
              resourcesData.add({
                'content': base64Content,
                'task_title': taskTitle,
              });
            } else {
              logger.warn('Resource file not found: ${resource.path}');
            }
          } catch (e) {
            logger.error('Error encoding resource ${resource.path}: $e');
            // 文件读取失败时记录日志并跳过
          }
        }

        // Construct exportable data using the data in the current state
        final exportData = {
          '__v': 2, // 版本号改为2
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
          'resources': resourcesData,
        };

        emit(ExportSuccess(
            exportData: exportData,
            useNewFormat: event.useNewFormat,
            projects: currentState.projects,
            labels: currentState.labels,
            tasks: currentState.tasks,
            resources: currentState.resources,
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
