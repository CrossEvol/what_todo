import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/reminder.dart';
import 'package:flutter_app/models/reminder_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderCreatePage extends StatefulWidget {
  final int taskId;

  const ReminderCreatePage({super.key, required this.taskId});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  ReminderType _selectedType = ReminderType.once;
  TimeOfDay? _selectedTime;
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blueGrey[800]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Reminder"),
      ),
      floatingActionButton: FloatingActionButton(
        key: ValueKey(ReminderPageKeys.CREATE_REMINDER),
        child: Icon(
          Icons.add_alarm_rounded,
          color: Colors.white,
        ),
        tooltip: 'create reminder',
        backgroundColor: Colors.purple,
        onPressed: () async {
          if (_selectedTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a time')),
            );
            return;
          }
          final now = DateTime.now();
          final remindTime = DateTime(now.year, now.month, now.day,
              _selectedTime!.hour, _selectedTime!.minute);
          final reminder = Reminder.create(
            _selectedType,
            remindTime,
            _isEnabled,
            widget.taskId,
          );
          context.read<ReminderBloc>().add(AddReminderEvent(reminder));
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'For Task',
                      style: textStyle,
                    ),
                    Text(
                      '#${widget.taskId}',
                      style: textStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Repetition',
                      style: textStyle,
                    ),
                    DropdownButton<ReminderType>(
                      value: _selectedType,
                      onChanged: (ReminderType? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                      items: ReminderType.values
                          .map<DropdownMenuItem<ReminderType>>(
                              (ReminderType value) {
                        return DropdownMenuItem<ReminderType>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'CronTime',
                      style: textStyle,
                    ),
                    ElevatedButton(
                      child: Text(_selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context)),
                      onPressed: () async {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _isEnabled ? "Enabled" : "Disabled",
                      style: textStyle,
                    ),
                    Switch(
                      value: _isEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
