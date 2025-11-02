import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart';
import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter_app/models/reminder/reminder_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReminderGrid extends StatefulWidget {
  const ReminderGrid({super.key});

  @override
  State<ReminderGrid> createState() => _ReminderGridState();
}

class _ReminderGridState extends State<ReminderGrid> {
  List<Reminder> reminders = <Reminder>[];
  late ReminderDataSource reminderDataSource;

  int _currentID = 0;
  TextEditingController? _taskIdController;
  TextEditingController? _remindTimeController;
  bool _currentEnable = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ReminderBloc>().add(const LoadAllReminders());
    _taskIdController = TextEditingController();
    _remindTimeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is ReminderInitial || state is ReminderLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ReminderLoaded) {
          reminders = state.remindersByTask.values.expand((x) => x).toList();
          reminderDataSource = ReminderDataSource(reminderData: reminders);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Reminders DataGrid'),
            ),
            body: SfDataGrid(
              source: reminderDataSource,
              allowSorting: true,
              allowSwiping: true,
              swipeMaxOffset: 121.0,
              endSwipeActionsBuilder: _buildEndSwipeWidget,
              startSwipeActionsBuilder: _buildStartSwipeWidget,
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'id',
                    visible: false,
                    label: Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: const Text('ID'))),
                GridColumn(
                    columnName: 'taskId',
                    label: Container(
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Task ID',
                        ))),
                GridColumn(
                    columnName: 'remindTime',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text('Remind Time'))),
                GridColumn(
                    columnName: 'enable',
                    label: Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text('Enabled'))),
              ],
            ),
          );
        }
        if (state is ReminderError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('提醒事项'),
          ),
          body: const Center(
            child: Text('提醒事项列表'),
          ),
        );
      },
    );
  }

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
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _formKey,
              child: _buildAlertDialogContent(setState),
            );
          },
        ),
      ),
    );
  }

  void _updateTextFieldContext(DataGridRow row) {
    _currentID = row
            .getCells()
            .firstWhere((element) => element.columnName == 'id')
            .value as int? ??
        0;

    _taskIdController!.text = row
            .getCells()
            .firstWhere((element) => element.columnName == 'taskId')
            .value
            ?.toString() ??
        '';

    final remindTime = row
        .getCells()
        .firstWhere((element) => element.columnName == 'remindTime')
        .value as DateTime?;
    _remindTimeController!.text = remindTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(remindTime)
        : '';
    _currentEnable = row
            .getCells()
            .firstWhere((element) => element.columnName == 'enable')
            .value as bool? ??
        true;
  }

  Widget _buildAlertDialogContent(StateSetter setState) {
    return SingleChildScrollView(
      child: Container(
        width: 300, // Adjust this value as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildRow(controller: _taskIdController!, columnName: 'Task ID'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text("Remind Time")),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _remindTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Select Date and Time',
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );
                          if (pickedTime != null) {
                            final dateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            setState(() {
                              _remindTimeController!.text =
                                  DateFormat('yyyy-MM-dd HH:mm')
                                      .format(dateTime);
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    flex: 2,
                    child: Text("Enable"),
                  ),
                  Expanded(
                    flex: 3,
                    child: Switch(
                      value: _currentEnable,
                      onChanged: (bool value) {
                        setState(() {
                          _currentEnable = value;
                        });
                      },
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

  Widget _buildRow(
      {required TextEditingController controller, required String columnName}) {
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
              controller: controller,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field cannot be empty';
                }
                return null;
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(DataGridRow row, BuildContext buildContext) {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellUpdate(row, buildContext),
        child: const Text('SAVE'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(buildContext),
        child: const Text('CANCEL'),
      ),
    ];
  }

  void _processCellUpdate(DataGridRow row, BuildContext buildContext) {
    if (_formKey.currentState!.validate()) {
      final updatedReminder = Reminder.update(
        id: _currentID,
        type: ReminderType.once, // Assuming default type for now
        remindTime: _remindTimeController!.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd HH:mm').parse(_remindTimeController!.text)
            : null,
        enable: _currentEnable,
        taskId: int.tryParse(_taskIdController!.text),
      );
      context
          .read<ReminderBloc>()
          .add(UpdateReminderEvent(updatedReminder));
      Navigator.pop(buildContext);
    }
  }

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

  void _handleDeleteWidgetTap(DataGridRow row) {
    final int? id = row
        .getCells()
        .firstWhere((element) => element.columnName == 'id')
        .value as int?;
    if (id == null) return;

    context.read<ReminderBloc>().add(RemoveReminderEvent(id));
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

class ReminderDataSource extends DataGridSource {
  ReminderDataSource({required List<Reminder> reminderData}) {
    dataGridRows = reminderData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<int>(columnName: 'taskId', value: e.taskId),
              DataGridCell<DateTime?>(
                  columnName: 'remindTime', value: e.remindTime),
              DataGridCell<bool>(columnName: 'enable', value: e.enable),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'id') {
        return const SizedBox.shrink();
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  void updateDataSource() {
    notifyListeners();
  }
}
