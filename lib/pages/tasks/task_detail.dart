import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  final List<Reminder> reminders;

  const TaskDetailPage(
      {super.key, required this.task, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                context.pushReplacement('/task/${task.id}/edit', extra: task);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(task.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            _buildTaskInfo(context),
            const SizedBox(height: 20),
            _buildProjectInfo(context),
            const SizedBox(height: 20),
            _buildLabelsInfo(context),
            const SizedBox(height: 20),
            _buildResourcesInfo(context),
            const SizedBox(height: 20),
            _buildRemindersInfo(context),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
                Navigator.of(context).pop();
                // It is necessary to check if the widget is still mounted before navigating
                if (!context.mounted) return;
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.push('/');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Details',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Title'),
              subtitle: Text(task.title),
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text('Comment'),
              subtitle: Text(task.comment),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text(getFormattedDate(task.dueDate)),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Priority'),
              subtitle: Text(task.priority.toString().split('.').last),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Status'),
              subtitle:
                  Text(task.tasksStatus?.toString().split('.').last ?? 'N/A'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Name'),
              subtitle: Text(task.projectName ?? 'Inbox'),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Color'),
              subtitle: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Color(task.projectColor ?? Colors.transparent.value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelsInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Labels', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            if (task.labelList.isEmpty)
              const ListTile(
                leading: Icon(Icons.label_off),
                title: Text('No labels for this task.'),
              )
            else
              Wrap(
                spacing: 8.0,
                children: task.labelList
                    .map((label) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Color(label.colorValue),
                          ),
                          label: Text(label.name),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Resources',
                    style: Theme.of(context).textTheme.headlineSmall),
                if (task.resources.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      context.push('/resource/edit?taskId=${task.id}');
                    },
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Manage'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (task.resources.isEmpty)
              const ListTile(
                leading: Icon(Icons.image_not_supported),
                title: Text('No resources attached to this task.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: task.resources.length,
                itemBuilder: (context, index) {
                  final resource = task.resources[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: File(resource.path).existsSync()
                          ? Image.file(
                              File(resource.path),
                              fit: BoxFit.cover,
                              height: 200.0,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200.0,
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 48.0,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Failed to load image',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 200.0,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 48.0,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Image not found',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reminders', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            if (reminders.isEmpty)
              const ListTile(
                leading: Icon(Icons.notifications_off),
                title: Text('No reminders for this task.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(
                        '${reminder.type.toString().split('.').last} at ${reminder.remindTime}'),
                    subtitle: Text(
                        'Enabled: ${reminder.enable}, Updated: ${reminder.updateTime}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
