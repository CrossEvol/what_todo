import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/reminder/reminder_type.dart';
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderUpdatePage extends StatefulWidget {
  final Reminder reminder;

  const ReminderUpdatePage({super.key, required this.reminder});

  @override
  State<ReminderUpdatePage> createState() => _ReminderUpdatePageState();
}

class _ReminderUpdatePageState extends State<ReminderUpdatePage> {
  late ReminderType _selectedType;
  late TimeOfDay? _selectedTime;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.reminder.type;
    _selectedTime = widget.reminder.remindTime != null
        ? TimeOfDay.fromDateTime(widget.reminder.remindTime!)
        : null;
    _isEnabled = widget.reminder.enable;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blueGrey[800]);

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Reminder #${widget.reminder.id}"),
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
                      '#${widget.reminder.taskId}',
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
            const SizedBox(height: 24), // 添加一些垂直间距
            Column(
              // 新添加的按钮列
              crossAxisAlignment: CrossAxisAlignment.stretch, // 使按钮宽度充满
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a time')),
                      );
                      return;
                    }
                    // Construct the updated reminder object
                    final now = DateTime.now();
                    final remindTime = DateTime(now.year, now.month, now.day,
                        _selectedTime!.hour, _selectedTime!.minute);

                    final updatedReminder = Reminder.update(
                      id: widget.reminder.id!, // Use the existing ID
                      type: _selectedType,
                      remindTime: remindTime,
                      enable: _isEnabled,
                      taskId: widget.reminder.taskId, // Use the existing Task ID
                    );

                    // Dispatch update event instead of direct DB insert
                    context
                        .read<ReminderBloc>()
                        .add(UpdateReminderEvent(updatedReminder));

                    // Handle potential state changes or show immediate feedback
                    // BlocBuilder or listener might be needed for more robust error handling,
                    // but for simple feedback and navigation, we can show success and pop.
                    // Real error handling from bloc would be better.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Updating reminder...')), // Indicate update is in progress
                    );
                    // Optionally wait for bloc state change or pop immediately
                    Navigator.pop(context); // Navigate back after dispatching event

                    // Note: For more robust error/success feedback,
                    // consider using a BlocListener or BlocConsumer around this widget
                    // to react to ReminderLoaded or ReminderError states.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 蓝色背景
                    foregroundColor: Colors.white, // 白色文本和图标
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.update), // 更新图标
                  label: const Text('UPDATE'),
                ),
                const SizedBox(height: 12), // 按钮之间的间距
                ElevatedButton.icon(
                  onPressed: () async {
                    if (widget.reminder.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot delete unsaved reminder')),
                      );
                      return;
                    }

                    final bool confirm = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('确认删除'),
                          content: const Text('您确定要删除此提醒吗？'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false), // 返回 false 表示取消
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true), // 返回 true 表示确认
                              child: const Text('删除'),
                            ),
                          ],
                        );
                      },
                    ) ?? false; // 如果对话框被 dismiss，默认为 false

                    if (confirm) {
                      try {
                        // Dispatch remove event
                        context
                            .read<ReminderBloc>()
                            .add(RemoveReminderEvent(widget.reminder.id!));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reminder deleted successfully')),
                        );
                        Navigator.pop(context); // Navigate back after deletion
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to delete reminder: $e')),
                        );
                      }
                    } // <-- Missing closing brace for if(confirm) block
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // 红色背景
                    foregroundColor: Colors.white, // 白色文本和图标
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete), // 删除图标
                  label: const Text('DELETE'),
                ),
                const SizedBox(height: 12), // 按钮之间的间距
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // 返回上一页
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // 灰色背景
                    foregroundColor: Colors.white, // 白色文本和图标
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_back), // 返回图标
                  label: const Text('BACK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
