import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/import/import_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../l10n/app_localizations.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  TextEditingController filePathController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultPath();
  }

  Future<void> _loadDefaultPath() async {
    String? importPath = await _getImportPath();
    if (importPath != null) {
      setState(() {
        filePathController.text = importPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.imports),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.input),
            onPressed: () {
              if (context.read<ImportBloc>().state is ImportLoaded) {
                context.read<ImportBloc>().add(const ConfirmImportEvent());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ImportBloc, ImportState>(
        builder: (context, state) {
          if (state is ImportInitial) {
            return _buildFileSelectionView();
          } else if (state is ImportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImportLoaded) {
            return _buildImportDataView(state);
          } else if (state is ImportConfirmed) {
            Future.delayed(const Duration(milliseconds: 100), () {
              context.read<ImportBloc>().add(ImportInProgressEvent(
                  projects: state.projects,
                  labels: state.labels,
                  tasks: state.tasks));
            });
            return _buildImportInProgressView();
          } else if (state is ImportInProgress) {
            return _buildImportInProgressView();
          } else if (state is ImportError) {
            return _buildErrorView(state);
          } else if (state is ImportSuccess) {
            Future.delayed(const Duration(milliseconds: 100), () {
              showSnackbar(
                  context, AppLocalizations.of(context)!.importSuccess);
            });
            return _buildFileSelectionView();
          } else {
            return _buildFileSelectionView();
          }
        },
      ),
    );
  }

  Widget _buildImportInProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.imports,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.importSuccess,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.imports,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.importFile,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 24),
          TextField(
            controller: filePathController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.filePath,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.folder_open),
                onPressed: _selectFile,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _importFile,
                  child: isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.0),
                            ),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.imports),
                          ],
                        )
                      : Text(AppLocalizations.of(context)!.importFile),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.imports,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text('• ' +
                      AppLocalizations.of(context)!.legacyFormat +
                      ' / ' +
                      AppLocalizations.of(context)!.newFormat),
                  Text('• ' + AppLocalizations.of(context)!.importSuccess),
                  Text('• ' + AppLocalizations.of(context)!.tasks),
                  Text('• ' +
                      AppLocalizations.of(context)!.projects +
                      ' / ' +
                      AppLocalizations.of(context)!.labels),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportDataView(ImportLoaded state) {
    return DefaultTabController(
      length: 3,
      initialIndex: state.currentTab.index,
      child: Column(
        children: [
          TabBar(
            onTap: (index) {
              ImportTab selectedTab = ImportTab.values[index];
              context.read<ImportBloc>().add(ChangeImportTabEvent(selectedTab));
            },
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tasks),
              Tab(text: AppLocalizations.of(context)!.projects),
              Tab(text: AppLocalizations.of(context)!.labels),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: IndexedStack(
              index: state.currentTab.index,
              children: [
                _buildTasksGrid(state),
                _buildProjectsGrid(state),
                _buildLabelsGrid(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksGrid(ImportLoaded state) {
    final taskDataSource = TaskDataSource(tasks: state.tasks);

    return SfDataGrid(
      source: taskDataSource,
      allowSwiping: true,
      swipeMaxOffset: 121.0,
      endSwipeActionsBuilder: (context, row, rowIndex) =>
          _buildTaskEndSwipeWidget(context, row, rowIndex),
      allowSorting: true,
      columnWidthMode: ColumnWidthMode.fill,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'title',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.name),
          ),
        ),
        GridColumn(
          columnName: 'projectName',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.project),
          ),
        ),
        GridColumn(
          columnName: 'labels',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.labels),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsGrid(ImportLoaded state) {
    final projectDataSource = ProjectDataSource(projects: state.projects);

    return SfDataGrid(
      source: projectDataSource,
      allowSwiping: true,
      swipeMaxOffset: 121.0,
      endSwipeActionsBuilder: (context, row, rowIndex) =>
          _buildProjectEndSwipeWidget(context, row, rowIndex),
      allowSorting: true,
      columnWidthMode: ColumnWidthMode.fill,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.name),
          ),
        ),
        GridColumn(
          columnName: 'count',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.count),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelsGrid(ImportLoaded state) {
    final labelDataSource = LabelDataSource(labels: state.labels);

    return SfDataGrid(
      source: labelDataSource,
      allowSwiping: true,
      swipeMaxOffset: 121.0,
      endSwipeActionsBuilder: (context, row, rowIndex) =>
          _buildLabelEndSwipeWidget(context, row, rowIndex),
      allowSorting: true,
      columnWidthMode: ColumnWidthMode.fill,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'name',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.name),
          ),
        ),
        GridColumn(
          columnName: 'count',
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.count),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskEndSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _handleDeleteTask(rowIndex),
      child: Container(
        color: Colors.redAccent,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 16.0),
            Text(AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectEndSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _showDeleteProjectDialog(rowIndex),
      child: Container(
        color: Colors.redAccent,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 16.0),
            Text(AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelEndSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _showDeleteLabelDialog(rowIndex),
      child: Container(
        color: Colors.redAccent,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 16.0),
            Text(AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _handleDeleteTask(int taskIndex) {
    context.read<ImportBloc>().add(DeleteTaskEvent(taskIndex: taskIndex));
  }

  void _showDeleteProjectDialog(int projectIndex) {
    bool deleteRelatedTasks = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.removeProject),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title:
                        Text(AppLocalizations.of(context)!.removeRelatedTasks),
                    value: true,
                    groupValue: deleteRelatedTasks,
                    onChanged: (value) {
                      setState(() {
                        deleteRelatedTasks = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title:
                        Text(AppLocalizations.of(context)!.onlyRemoveProject),
                    value: false,
                    groupValue: deleteRelatedTasks,
                    onChanged: (value) {
                      setState(() {
                        deleteRelatedTasks = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<ImportBloc>().add(DeleteProjectEvent(
                          projectIndex: projectIndex,
                          deleteRelatedTasks: deleteRelatedTasks,
                        ));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteLabelDialog(int labelIndex) {
    bool deleteRelatedTasks = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.removeLabel),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title:
                        Text(AppLocalizations.of(context)!.removeRelatedTasks),
                    value: true,
                    groupValue: deleteRelatedTasks,
                    onChanged: (value) {
                      setState(() {
                        deleteRelatedTasks = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(AppLocalizations.of(context)!.onlyRemoveLabel),
                    value: false,
                    groupValue: deleteRelatedTasks,
                    onChanged: (value) {
                      setState(() {
                        deleteRelatedTasks = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<ImportBloc>().add(DeleteLabelEvent(
                          labelIndex: labelIndex,
                          deleteRelatedTasks: deleteRelatedTasks,
                        ));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(ImportError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.importError + ': ' + state.message,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.goBack),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePathController.text = result.files.single.path!;
      });
    }
  }

  Future<void> _importFile() async {
    if (filePathController.text.isEmpty) {
      showSnackbar(context, AppLocalizations.of(context)!.noFileSelected,
          materialColor: Colors.red);
      return;
    }

    // Check for storage permissions first
    bool hasPermission = await _checkAndRequestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      File file = File(filePathController.text);
      if (!await file.exists()) {
        showSnackbar(
            context,
            AppLocalizations.of(context)!.importError +
                ': ' +
                AppLocalizations.of(context)!.fileNotFound,
            materialColor: Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      String fileContent;
      try {
        fileContent = await file.readAsString();
      } catch (e) {
        logger.warn('Error reading file: $e');
        showSnackbar(
            context,
            AppLocalizations.of(context)!.importError +
                ': ' +
                AppLocalizations.of(context)!.cannotReadFile,
            materialColor: Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      dynamic jsonData;
      try {
        jsonData = jsonDecode(fileContent);
      } catch (e) {
        logger.warn('Error parsing JSON: $e');
        showSnackbar(
            context,
            AppLocalizations.of(context)!.importError +
                ': ' +
                AppLocalizations.of(context)!.invalidJsonFormat,
            materialColor: Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Send the data to the Import Bloc
      context.read<ImportBloc>().add(ImportLoadDataEvent(jsonData));
    } catch (e) {
      logger.warn('Import error: $e');
      showSnackbar(context,
          AppLocalizations.of(context)!.importError + ': ' + e.toString(),
          materialColor: Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to check and request storage permissions
  Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // Only Android needs explicit permission handling
      return true;
    }

    // For Android 10 (API level 29) and below
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      // User permanently denied permission, we need to ask them to enable from settings
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.storagePermissionRequired),
          content: Text(
            AppLocalizations.of(context)!.storagePermissionRequired,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.settings),
              onPressed: () => openAppSettings(),
            ),
          ],
        ),
      );
      return false;
    }

    // Request permission
    status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else {
      // User denied permission this time
      showSnackbar(
          context, AppLocalizations.of(context)!.storagePermissionRequired,
          materialColor: Colors.red);
      return false;
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
  TaskDataSource({required List<Task> tasks}) {
    _tasks = tasks
        .map<DataGridRow>((task) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'title', value: task.title),
              DataGridCell<String>(
                  columnName: 'projectName',
                  value: task.projectName ?? 'Inbox'),
              DataGridCell<String>(
                  columnName: 'labels',
                  value: task.labelList.isNotEmpty
                      ? (task.labelList.length > 2
                          ? '${task.labelList.take(2).map((label) => label.name).join(", ")}...'
                          : task.labelList
                              .map((label) => label.name)
                              .join(", "))
                      : ''),
            ]))
        .toList();
  }

  List<DataGridRow> _tasks = [];

  @override
  List<DataGridRow> get rows => _tasks;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}

class ProjectDataSource extends DataGridSource {
  ProjectDataSource({required List<ProjectWithCount> projects}) {
    _projects = projects
        .map<DataGridRow>((project) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: project.name),
              DataGridCell<int>(columnName: 'count', value: project.count),
            ]))
        .toList();
  }

  List<DataGridRow> _projects = [];

  @override
  List<DataGridRow> get rows => _projects;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}

class LabelDataSource extends DataGridSource {
  LabelDataSource({required List<LabelWithCount> labels}) {
    _labels = labels
        .map<DataGridRow>((label) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: label.name),
              DataGridCell<int>(columnName: 'count', value: label.count),
            ]))
        .toList();
  }

  List<DataGridRow> _labels = [];

  @override
  List<DataGridRow> get rows => _labels;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}
