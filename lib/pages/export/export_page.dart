import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/export/export_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ExportView();
  }
}

class ExportView extends StatelessWidget {
  const ExportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ExportBloc, ExportState>(
        builder: (context, state) {
          if (state is ExportInitial) {
            context.read<ExportBloc>().add(LoadExportDataEvent());
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExportLoaded) {
            return _buildTabbedContent(context, state);
          } else if (state is ExportError) {
            return Center(
              child: Text(
                'Error: ${(state).message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is ExportSuccess) {
            _performExport(context, state);
            Future.delayed(const Duration(milliseconds: 100), () {
              int countdown = 3;
              Timer.periodic(const Duration(seconds: 1), (timer) {
                countdown--;
                if (countdown <= 0) {
                  timer.cancel();
                  context.push('/');
                  context.read<ExportBloc>().add(ResetExportDataEvent());
                }
              });
            });

            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Export completed successfully!'),
                const SizedBox(height: 16),
                const Text('Redirecting to home in...'),
                TweenAnimationBuilder(
                  tween: Tween(begin: 3.0, end: 0.0),
                  duration: const Duration(seconds: 3),
                  builder: (_, double value, __) {
                    return Text(
                      '${value.ceil()}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildTabbedContent(BuildContext context, ExportLoaded state) {
    return Column(
      children: [
        _buildTabBar(context, state),
        Expanded(
          child: _buildTabContent(context, state),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, ExportLoaded state) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(
            context,
            'Tasks',
            state.currentTab == ExportTab.tasks,
            () => context
                .read<ExportBloc>()
                .add(const ChangeTabEvent(tab: ExportTab.tasks)),
          ),
          _buildTabButton(
            context,
            'Projects',
            state.currentTab == ExportTab.projects,
            () => context
                .read<ExportBloc>()
                .add(const ChangeTabEvent(tab: ExportTab.projects)),
          ),
          _buildTabButton(
            context,
            'Labels',
            state.currentTab == ExportTab.labels,
            () => context
                .read<ExportBloc>()
                .add(const ChangeTabEvent(tab: ExportTab.labels)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ExportLoaded state) {
    switch (state.currentTab) {
      case ExportTab.tasks:
        return _buildTasksGrid(context, state);
      case ExportTab.projects:
        return _buildProjectsGrid(context, state);
      case ExportTab.labels:
        return _buildLabelsGrid(context, state);
      case null:
        // Default to tasks if tab is null
        return _buildTasksGrid(context, state);
    }
  }

  Widget _buildTasksGrid(BuildContext context, ExportLoaded state) {
    final dataSource = TaskDataSource(tasks: state.tasks!);

    return Padding(
      padding: const EdgeInsets.all(0), // Remove padding to use full width
      child: SfDataGrid(
        source: dataSource,
        allowSwiping: true,
        allowSorting: true,
        swipeMaxOffset: 100.0,
        columnWidthMode: ColumnWidthMode.fill,
        // Fill the available width
        endSwipeActionsBuilder: (_, DataGridRow row, int rowIndex) {
          return GestureDetector(
            onTap: () {
              final taskId = dataSource.tasks[rowIndex].id;
              if (taskId != null) {
                context.read<ExportBloc>().add(DeleteTaskEvent(taskId: taskId));
              }
            },
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        columns: <GridColumn>[
          GridColumn(
            columnName: 'name',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Name'),
            ),
          ),
          GridColumn(
            columnName: 'project',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Project'),
            ),
          ),
          GridColumn(
            columnName: 'labels',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Labels'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, ExportLoaded state) {
    final dataSource = ProjectDataSource(projects: state.projects!);

    return Padding(
      padding: const EdgeInsets.all(0), // Remove padding to use full width
      child: SfDataGrid(
        source: dataSource,
        allowSwiping: true,
        allowSorting: true,
        swipeMaxOffset: 100.0,
        columnWidthMode: ColumnWidthMode.fill,
        // Fill the available width
        endSwipeActionsBuilder: (_, DataGridRow row, int rowIndex) {
          return GestureDetector(
            onTap: () => _showDeleteProjectDialog(
              context,
              state.projects![rowIndex],
            ),
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        columns: <GridColumn>[
          GridColumn(
            columnName: 'name',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Name'),
            ),
          ),
          GridColumn(
            columnName: 'count',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Count'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsGrid(BuildContext context, ExportLoaded state) {
    final dataSource = LabelDataSource(labels: state.labels!);

    return Padding(
      padding: const EdgeInsets.all(0), // Remove padding to use full width
      child: SfDataGrid(
        source: dataSource,
        allowSwiping: true,
        allowSorting: true,
        swipeMaxOffset: 100.0,
        columnWidthMode: ColumnWidthMode.fill,
        // Fill the available width
        endSwipeActionsBuilder: (_, DataGridRow row, int rowIndex) {
          return GestureDetector(
            onTap: () => _showDeleteLabelDialog(
              context,
              state.labels![rowIndex],
            ),
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        columns: <GridColumn>[
          GridColumn(
            columnName: 'name',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Name'),
            ),
          ),
          GridColumn(
            columnName: 'count',
            width: double.nan, // Use NaN to make it flexible
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Count'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteProjectDialog(
      BuildContext context, ProjectWithCount project) {
    bool deleteRelatedTasks = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Remove Project'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose an option:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RadioListTile<bool>(
                  title: const Text('Remove related tasks'),
                  value: true,
                  groupValue: deleteRelatedTasks,
                  onChanged: (value) {
                    setState(() => deleteRelatedTasks = value!);
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('Only remove project'),
                  value: false,
                  groupValue: deleteRelatedTasks,
                  onChanged: (value) {
                    setState(() => deleteRelatedTasks = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ExportBloc>().add(
                        DeleteProjectEvent(
                          projectId: project.id,
                          deleteRelatedTasks: deleteRelatedTasks,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteLabelDialog(BuildContext context, LabelWithCount label) {
    bool deleteRelatedTasks = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Remove Label'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose an option:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RadioListTile<bool>(
                  title: const Text('Remove related tasks'),
                  value: true,
                  groupValue: deleteRelatedTasks,
                  onChanged: (value) {
                    setState(() => deleteRelatedTasks = value!);
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('Only remove label'),
                  value: false,
                  groupValue: deleteRelatedTasks,
                  onChanged: (value) {
                    setState(() => deleteRelatedTasks = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ExportBloc>().add(
                        DeleteLabelEvent(
                          labelId: label.id,
                          deleteRelatedTasks: deleteRelatedTasks,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format'),
        content: const Text(
          'Choose the export format:',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ExportBloc>().add(
                    const ExportDataEvent(useNewFormat: true),
                  );
              Navigator.pop(context);
            },
            child: const Text('New Format (v2)'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context, ExportSuccess state) async {
    // Check for storage permissions first
    bool hasPermission = await _checkAndRequestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

    try {
      String json;
      if (state.useNewFormat) {
        // Export with new format (v2)
        const encoder = JsonEncoder.withIndent('  ');
        json = encoder.convert(state.exportData);
      } else {
        // Export with old format (v0) - extract just tasks
        final tasks = state.exportData['tasks'] as List;
        const encoder = JsonEncoder.withIndent('  ');
        json = encoder.convert(tasks);
      }

      var importPath = await _getImportPath();

      if (importPath != null) {
        try {
          var file = File('$importPath');
          // Create directory if it doesn't exist
          final dir = Directory(p.dirname(importPath));
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }

          await file.writeAsString(json);

          // 处理图片资源导出
          if (state.useNewFormat && state.exportData.containsKey('resources')) {
            await _exportResources(context,
                state.exportData['resources'] as List, p.dirname(importPath));
          }

          showSnackbar(context, 'Export Success: $importPath');
        } catch (e) {
          logger.warn('Error writing to file: $e');
          // Try one more time with application documents directory as fallback
          final directory = await getApplicationDocumentsDirectory();
          final fallbackPath = p.join(directory.path, 'tasks.json');

          try {
            var file = File(fallbackPath);
            await file.writeAsString(json);

            // 处理图片资源导出
            if (state.useNewFormat &&
                state.exportData.containsKey('resources')) {
              await _exportResources(context,
                  state.exportData['resources'] as List, directory.path);
            }

            showSnackbar(context, 'Export Success: $fallbackPath');
          } catch (e2) {
            logger.warn('Error writing to fallback location: $e2');
            showSnackbar(
              context,
              'Export Error: Storage permissions required',
              materialColor: Colors.red,
            );
          }
        }
      } else {
        showSnackbar(context, 'Export Error', materialColor: Colors.red);
      }
    } catch (e) {
      logger.warn('Export error: $e');
      showSnackbar(
        context,
        'Export Error: $e',
        materialColor: Colors.red,
      );
    }
  }

  Future<void> _exportResources(
      BuildContext context, List<dynamic> resources, String exportDir) async {
    if (resources.isEmpty) return;

    try {
      // 创建 resources 文件夹
      final resourcesDir = Directory(p.join(exportDir, 'resources'));
      if (!await resourcesDir.exists()) {
        await resourcesDir.create(recursive: true);
      }

      // 逐个复制文件，避免并发导致的文件锁定问题
      for (final resource in resources) {
        try {
          final resourceMap = resource as Map<String, dynamic>;
          final sourcePath = resourceMap['path'] as String;
          final sourceFile = File(sourcePath);

          if (await sourceFile.exists()) {
            final fileName = p.basename(sourcePath);
            final destPath = p.join(resourcesDir.path, fileName);
            final destFile = File(destPath);

            // 只有当目标文件不存在时才复制
            if (!await destFile.exists()) {
              // 使用字节流复制，确保文件句柄正确关闭
              final sourceBytes = await sourceFile.readAsBytes();
              await destFile.writeAsBytes(sourceBytes);
              
              // 添加小延迟确保文件操作完成
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        } catch (e) {
          logger.warn('Error copying resource ${resource['path']}: $e');
          // 继续处理下一个文件
          continue;
        }
      }

      logger.info('Resources exported successfully');
    } catch (e) {
      logger.warn('Error exporting resources: $e');
      // 不抛出异常，让主导出流程继续
    }
  }

  // Method to check and request storage permissions
  Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // Only Android needs explicit permission handling
      return true;
    }

    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    logger.info('Android SDK Version: $sdkVersion');

    if (sdkVersion >= 33) {
      // Android 13+ (API 33+) - request granular media permissions
      PermissionStatus imageStatus = await Permission.photos.status;

      if (imageStatus.isGranted) {
        return true;
      }

      if (imageStatus.isPermanentlyDenied) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      // Request permission
      imageStatus = await Permission.photos.request();
      if (imageStatus.isGranted) {
        return true;
      } else {
        showSnackbar(
          context,
          'Export Error: Media permissions required',
          materialColor: Colors.red,
        );
        return false;
      }
    } else if (sdkVersion >= 30) {
      // Android 11-12 (API 30-32) - Check for MANAGE_EXTERNAL_STORAGE if needed
      // or fall back to storage permission for limited access

      // First try with regular storage permissions (limited access)
      PermissionStatus status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // If regular storage permission denied or we need full access,
      // we might need to request MANAGE_EXTERNAL_STORAGE
      bool hasFullAccess = await Permission.manageExternalStorage.isGranted;

      if (hasFullAccess) {
        return true;
      }

      // Show dialog to request full storage access
      bool shouldRequestFull = await _showRequestFullStorageDialog(context);

      if (shouldRequestFull) {
        await Permission.manageExternalStorage.request();
        hasFullAccess = await Permission.manageExternalStorage.isGranted;

        if (!hasFullAccess) {
          showSnackbar(
            context,
            'Full storage access is required for this feature.',
            materialColor: Colors.red,
          );
        }

        return hasFullAccess;
      } else {
        return false;
      }
    } else {
      // Android 10 and below (API 29-) - Traditional storage permissions
      PermissionStatus status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      // Request permission
      status = await Permission.storage.request();

      if (status.isGranted) {
        return true;
      } else {
        showSnackbar(
          context,
          'Export Error: Storage permissions required',
          materialColor: Colors.red,
        );
        return false;
      }
    }
  }

  void _showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'Export Error: Storage permissions are required. Please enable them in app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Settings'),
            onPressed: () => openAppSettings(),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRequestFullStorageDialog(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Full Storage Access Required'),
        content: const Text(
          'This feature requires full access to storage. You will be redirected to settings to grant this permission.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Continue'),
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return result;
  }

  Future<String?> _getImportPath() async {
    const filename = 'tasks.json';
    String? dest;

    try {
      if (Platform.isAndroid) {
        // Try to get the app-specific external storage directory first
        var directory = await getExternalStorageDirectory();
        dest = directory?.path;

        // If that fails, fall back to application documents directory
        if (dest == null) {
          var docDirectory = await getApplicationDocumentsDirectory();
          dest = docDirectory.path;
        }
      } else if (Platform.isWindows) {
        var directory = await getApplicationDocumentsDirectory();
        dest = directory.path;
      } else {
        // For iOS and other platforms
        var directory = await getApplicationDocumentsDirectory();
        dest = directory.path;
      }

      // Make sure the directory exists
      final dir = Directory(dest);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return p.join(dest, filename);
    } catch (e) {
      logger.warn('Error getting import/export path: $e');
      // Fallback to app documents directory
      try {
        final directory = await getApplicationDocumentsDirectory();
        return p.join(directory.path, filename);
      } catch (_) {
        return null;
      }
    }
  }
}

class TaskDataSource extends DataGridSource {
  final List<Task> tasks;

  TaskDataSource({required this.tasks}) {
    _buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = tasks.map<DataGridRow>((task) {
      // Truncate label names if too long
      String labelNames = task.labelList.map((label) => label.name).join(', ');
      if (labelNames.length > 30) {
        labelNames = labelNames.substring(0, 27) + '...';
      }

      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: task.title),
        DataGridCell<String>(
            columnName: 'project', value: task.projectName ?? 'Inbox'),
        DataGridCell<String>(columnName: 'labels', value: labelNames),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class ProjectDataSource extends DataGridSource {
  final List<ProjectWithCount> projects;

  ProjectDataSource({required this.projects}) {
    _buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = projects.map<DataGridRow>((project) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: project.name),
        DataGridCell<int>(columnName: 'count', value: project.count),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class LabelDataSource extends DataGridSource {
  final List<LabelWithCount> labels;

  LabelDataSource({required this.labels}) {
    _buildDataGridRows();
  }

  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = labels.map<DataGridRow>((label) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: label.name),
        DataGridCell<int>(columnName: 'count', value: label.count),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}
