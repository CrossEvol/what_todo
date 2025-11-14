import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/export/export_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/cubit/github_cubit.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_app/utils/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  void _showExportDialog(BuildContext context) async {
    String selectedDestination = 'local';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Export Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Where would you like to export?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                RadioListTile<String>(
                  title: const Text('Local Storage'),
                  value: 'local',
                  groupValue: selectedDestination,
                  onChanged: (value) {
                    setState(() => selectedDestination = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('GitHub Repository'),
                  value: 'github',
                  groupValue: selectedDestination,
                  onChanged: (value) {
                    setState(() => selectedDestination = value!);
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Format: v2 (JSON)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, selectedDestination),
                child: const Text('Export'),
              ),
            ],
          );
        },
      ),
    );

    if (result == null) return;

    if (result == 'github') {
      await _handleGitHubExport(context);
    } else {
      // Local export
      context.read<ExportBloc>().add(
            const ExportDataEvent(useNewFormat: true),
          );
    }
  }

  Future<void> _handleGitHubExport(BuildContext context) async {
    // Check if GitHub credentials are configured
    final githubCubit = context.read<GitHubCubit>();
    if (!githubCubit.isConfigured) {
      final shouldNavigate = await _showGitHubNotConfiguredDialog(context);
      if (shouldNavigate == true) {
        context.push('/github_config');
      }
      return;
    }

    // Check if GitHub export is enabled in settings
    final settingsBloc = context.read<SettingsBloc>();
    if (!settingsBloc.state.enableGitHubExport) {
      final shouldNavigate = await _showGitHubExportDisabledDialog(context);
      if (shouldNavigate == true) {
        context.push('/settings');
      }
      return;
    }

    // TODO: Trigger GitHub export (will be implemented in task 16)
    // For now, just show a message
    showSnackbar(
      context,
      'GitHub export will be implemented in the next task',
    );
  }

  Future<bool?> _showGitHubNotConfiguredDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Not Configured'),
        content: const Text(
          'GitHub credentials are not configured. Would you like to set them up now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showGitHubExportDisabledDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Export Disabled'),
        content: const Text(
          'GitHub export is currently disabled in settings. Would you like to enable it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context, ExportSuccess state) async {
    // Check for storage permissions first
    bool hasPermission = await PermissionHandlerService.instance
        .checkAndRequestStoragePermission(context);
    if (!hasPermission) {
      showSnackbar(
        context,
        'Export Error: Storage permissions required',
        materialColor: Colors.red,
      );
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
          showSnackbar(context, 'Export Success: $importPath');
        } catch (e) {
          logger.warn('Error writing to file: $e');
          // Try one more time with application documents directory as fallback
          final directory = await getApplicationDocumentsDirectory();
          final fallbackPath = p.join(directory.path, 'tasks.json');

          try {
            var file = File(fallbackPath);
            await file.writeAsString(json);
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
