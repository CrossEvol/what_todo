import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart'; // Import SettingsBloc
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/l10n/app_localizations.dart'; // Import localizations
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// The home page of the application which hosts the datagrid.
class ProjectGridPage extends StatefulWidget {
  /// Creates the home page.
  const ProjectGridPage({super.key});

  @override
  State<ProjectGridPage> createState() => _ProjectGridPageState();
}

class _ProjectGridPageState extends State<ProjectGridPage> {
  List<ProjectWithCount> projects = <ProjectWithCount>[];
  late ProjectDataSource projectDataSource;
  int _currentID = 0;
  TextEditingController? _idController;
  TextEditingController? _nameController;
  TextEditingController? _countController;

  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    var state = context.read<ProjectBloc>().state;
    if (state is ProjectsLoadedState) {
      projects = state.projectsWithCount;
    }
    projectDataSource = ProjectDataSource(projectData: projects);
    _idController = TextEditingController();
    _nameController = TextEditingController();
    _countController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectInitialState) {
          return CircularProgressIndicator();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Projects DataGrid'),
          ),
          body: SfDataGrid(
            source: projectDataSource,
            allowSwiping: true,
            swipeMaxOffset: 121.0,
            endSwipeActionsBuilder: _buildEndSwipeWidget,
            startSwipeActionsBuilder: _buildStartSwipeWidget,
            allowSorting: true,
            allowEditing: true,
            columnWidthMode: ColumnWidthMode.fill,
            columns: <GridColumn>[
              GridColumn(
                  columnName: 'id',
                  label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text(
                        'ID',
                      ))),
              GridColumn(
                  columnName: 'name',
                  label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: const Text('Name'))),
              GridColumn(
                  columnName: 'count',
                  label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: const Text('Count'))),
              GridColumn(
                  columnName: 'colorName',
                  visible: false,
                  label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: const Text('ColorName'))),
              GridColumn(
                  columnName: 'colorCode',
                  visible: false,
                  label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: const Text('ColorCode'))),
            ],
          ),
        );
      },
    );
  }

  List<Widget> buildMaterialColors(BuildContext context) {
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          context.read<AdminBloc>().add(
                AdminUpdateColorSelectionEvent(
                  colorPalette:
                      ColorPalette(colors.colorName, colors.colorValue),
                ),
              );
        },
      ));
    });
    return projectWidgetList;
  }

  /// Callback for left swiping, and it will flipped for RTL case
  Widget _buildStartSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _handleEditWidgetTap(row),
      child: Container(
        color: Colors.blueAccent,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.edit, color: Colors.white, size: 20),
            SizedBox(width: 16.0),
            Text(
              'EDIT',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }

  /// Editing the DataGridRow
  void _handleEditWidgetTap(DataGridRow row) {
    _updateTextFieldContext(row);
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Edit Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        actions: _buildActionButtons(row, context),
        content: Form(
          key: _formKey,
          child: _buildAlertDialogContent(),
        ),
      ),
    );
  }

  // Updating the data to the TextEditingController
  void _updateTextFieldContext(DataGridRow row) {
    final String? id = row
        .getCells()
        .where((element) => element.columnName == 'id')
        .firstOrNull
        ?.value
        .toString();
    _currentID = int.tryParse(id!) ?? 0;
    _idController!.text = id ?? '';
    final String? name = row
        .getCells()
        .where((element) => element.columnName == 'name')
        .firstOrNull
        ?.value
        .toString();
    _nameController!.text = name ?? '';
    final String? colorCode = row
        .getCells()
        .where((element) => element.columnName == 'colorCode')
        .firstOrNull
        ?.value
        .toString();
    final String? colorName = row
        .getCells()
        .where((element) => element.columnName == 'colorName')
        .firstOrNull
        ?.value
        .toString();
    context.read<AdminBloc>().add(AdminUpdateColorSelectionEvent(
            colorPalette: ColorPalette(
          colorName ?? 'Grey',
          colorCode!.isNotEmpty ? int.parse(colorCode) : Colors.grey.value,
        )));
    final String? count = row
        .getCells()
        .where((element) => element.columnName == 'count')
        .firstOrNull
        ?.value
        .toString();
    _countController!.text = count ?? '';
  }

  /// Building the forms to edit the data
  Widget _buildAlertDialogContent() {
    return SingleChildScrollView(
      child: Container(
        width: 300, // Adjust this value as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildRow(controller: _idController!, columnName: 'ID'),
            _buildRow(controller: _nameController!, columnName: 'Name'),
            _buildRow(controller: _countController!, columnName: 'Count'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Color'),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: BlocConsumer<AdminBloc, AdminState>(
                      builder: (context, state) {
                        if (state is AdminLoadedState) {
                          return CollapsibleExpansionTile(
                            key: expansionTile,
                            leading: Icon(
                              Icons.label,
                              size: 16.0,
                              color: Color(state.colorPalette.colorValue),
                            ),
                            title: Text(state.colorPalette.colorName),
                            children: buildMaterialColors(context),
                          );
                        }
                        return CollapsibleExpansionTile(
                          key: expansionTile,
                          leading: Icon(
                            Icons.label,
                            size: 16.0,
                            color: Color(Colors.grey.value),
                          ),
                          title: Text("Grey"),
                          children: buildMaterialColors(context),
                        );
                      },
                      listener: (BuildContext context, AdminState state) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  RegExp _makeRegExp(TextInputType keyboardType, String columnName) {
    return keyboardType == TextInputType.number
        ? columnName == 'Freight' || columnName == 'Price'
            ? RegExp('[0-9.]')
            : RegExp('[0-9]')
        : RegExp('[a-zA-Z ]');
  }

  /// Building the each field with label and TextFormField
  Widget _buildRow(
      {required TextEditingController controller, required String columnName}) {
    // Access SettingsBloc state here
    final settingsState = context.read<SettingsBloc>().state;
    final projectMaxLength = settingsState.projectLen;

    final bool isTextInput = <String>[
      'Name',
    ].contains(columnName);
    final TextInputType keyboardType =
        isTextInput ? TextInputType.text : TextInputType.number;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(columnName),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  // Use localization if available, otherwise fallback
                  return AppLocalizations.of(context)?.fieldCannotBeEmpty ??
                      'Field must not be empty';
                }
                if (columnName == 'Name' && value.length > projectMaxLength) {
                  // Use localization if available, otherwise fallback
                  return AppLocalizations.of(context)
                          ?.valueTooLong(projectMaxLength) ??
                      'Value cannot be longer than $projectMaxLength characters';
                }
                return null;
              },
              maxLength: columnName == 'Name' ? projectMaxLength : null,
              // Apply maxLength only to Name
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: isTextInput
                  ? null // Remove input formatters for text fields
                  : <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
            ),
          )
        ],
      ),
    );
  }

  /// Building the option button on the bottom of the alert popup
  List<Widget> _buildActionButtons(DataGridRow row, BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellUpdate(row, buildContext),
        child: const Text(
          'SAVE',
          style: TextStyle(),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: const Text(
          'CANCEL',
          style: TextStyle(),
        ),
      ),
    ];
  }

  /// Updating the DataGridRows after changing the value and notify the DataGrid
  /// to refresh the view
  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    final int rowIndex = projectDataSource.dataGridRows.indexOf(row);

    final colorPalette = context.read<AdminBloc>().state.colorPalette;
    if (_formKey.currentState!.validate()) {
      context.read<ProjectBloc>().add(ProjectUpdateEvent(
              project: Project.update(
            id: _currentID,
            name: _nameController!.text,
            colorCode: colorPalette.colorValue,
            colorName: colorPalette.colorName,
          )));
      projectDataSource.dataGridRows[rowIndex] = ProjectWithCount(
        id: _currentID,
        name: _nameController!.text,
        count: int.tryParse(_countController!.text) ?? 0,
        colorCode: colorPalette.colorValue,
        colorName: colorPalette.colorName,
      ).mapProjectRow();
      projectDataSource.updateDataSource();
      Navigator.pop(buildContext);
    }
  }

  /// Callback for right swiping, and it will flipped for RTL case
  Widget _buildEndSwipeWidget(
      BuildContext context, DataGridRow row, int rowIndex) {
    return GestureDetector(
      onTap: () => _handleDeleteWidgetTap(row),
      child: Container(
        color: Colors.redAccent,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 16.0),
            Text(
              'DELETE',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  /// Deleting the DataGridRow
  void _handleDeleteWidgetTap(DataGridRow row) {
    final String? id = row
        .getCells()
        .where((element) => element.columnName == 'id')
        .firstOrNull
        ?.value
        .toString();
    if (id == null) return;
    if (id.isEmpty) {
      return;
    }
    context.read<ProjectBloc>().add(ProjectRemoveEvent(
          projectID: int.parse(id),
        ));
    projectDataSource.dataGridRows.remove(row);
    projectDataSource.updateDataSource();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
        content: const Text('Row deleted successfully'),
      ),
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class ProjectDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ProjectDataSource({required List<ProjectWithCount> projectData}) {
    _projectData =
        projectData.map<DataGridRow>((e) => e.mapProjectRow()).toList();
  }

  List<DataGridRow> _projectData = [];

  List<DataGridRow> get dataGridRows => _projectData;

  @override
  List<DataGridRow> get rows => _projectData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  /// Update DataSource
  void updateDataSource() {
    notifyListeners();
  }
}
