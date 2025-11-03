import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/bloc/reminder/reminder_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/bloc/resource/resource_bloc.dart';
import 'package:flutter_app/models/reminder/reminder.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'models/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  PriorityStatus selectedPriority = PriorityStatus.PRIORITY_4;
  Project selectedProject = Project.inbox();
  List<Label> selectedLabels = [];
  int selectedDueDate = DateTime.now().millisecondsSinceEpoch;

  List<int> get labelIds => (selectedLabels..sort((a, b) => a.id! - b.id!))
      .map((label) => label.id!)
      .toList();

  String get labelNames => selectedLabels.isNotEmpty
      ? (selectedLabels..sort((a, b) => a.id! - b.id!))
          .map((label) => label.name)
          .join(", ")
      : "No Labels";

  // Regular expression to match URLs
  final RegExp _urlRegExp = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    caseSensitive: false,
  );

  bool get hasUrl =>
      _urlRegExp.hasMatch(_titleController.text) ||
      _urlRegExp.hasMatch(_commentController.text);

  String? get detectedUrl {
    var titleMatch = _urlRegExp.firstMatch(_titleController.text);
    if (titleMatch != null) {
      return titleMatch.group(0);
    }

    var commentMatch = _urlRegExp.firstMatch(_commentController.text);
    if (commentMatch != null) {
      return commentMatch.group(0);
    }

    return null;
  }

  String get commentPreview {
    if (_commentController.text.isEmpty) {
      return AppLocalizations.of(context)!.noComments;
    }
    if (_commentController.text.length <= 40) {
      return _commentController.text;
    }
    return "${_commentController.text.substring(0, 40)}...";
  }

  @override
  void initState() {
    super.initState();
    // if the projects is empty, will trigger no element error
    final projects = context
        .read<ProjectBloc>()
        .state
        .projectsWithCount
        .map((p) => p.trimCount())
        .toList();
    final labels = context.read<LabelBloc>().state.labels;
    _titleController.text = widget.task.title;
    _commentController.text = widget.task.comment;
    selectedPriority = widget.task.priority;
    // TODO: it will confirm the EditTask rendering, but will interfere the value of current task
    selectedProject = projects.isNotEmpty
        ? projects.where((p) => p.id == widget.task.projectId).first
        : Project.inbox();
    selectedDueDate = widget.task.dueDate;
    selectedLabels = widget.task.labelList.isNotEmpty
        ? labels
            .where((l) => widget.task.labelList
                .map((item) => item.name)
                .toList()
                .contains(l.name))
            .toList()
        : [];

    // Load resources for this task
    if (widget.task.id != null) {
      context.read<ResourceBloc>().add(LoadResourcesEvent(widget.task.id!));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editTask,
          key: ValueKey(EditTaskKeys.Edit_TASK_TITLE),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                icon: Icon(Icons.display_settings),
                onPressed: () {
                  context.push('/task/${widget.task.id}/detail');
                }),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          _TaskInputForm(
            formKey: _formState,
            titleController: _titleController,
            validator: (value) {
              return value!.isEmpty
                  ? AppLocalizations.of(context)!.titleCannotBeEmpty
                  : null;
            },
            titleKey: EditTaskKeys.Edit_TITLE,
          ),
          ListTile(
            key: ValueKey("editProject"),
            leading: Icon(Icons.book),
            title: Text(AppLocalizations.of(context)!.project),
            subtitle: Text(selectedProject.name),
            hoverColor: _grey,
            onTap: () {
              _showProjectsDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(AppLocalizations.of(context)!.dueDate),
            subtitle: Text(getFormattedDate(selectedDueDate)),
            hoverColor: _grey,
            onTap: () {
              _showDatePicker(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text(AppLocalizations.of(context)!.priority),
            subtitle: Text(priorityText[selectedPriority.index]),
            hoverColor: _grey,
            onTap: () {
              _showPriorityDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.label),
            title: Text(AppLocalizations.of(context)!.labels),
            subtitle: Text(labelNames),
            hoverColor: _grey,
            onTap: () {
              _showLabelsDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.mode_comment),
            title: Text(AppLocalizations.of(context)!.comments),
            subtitle: Text(commentPreview),
            trailing: hasUrl
                ? IconButton(
                    icon: Icon(Icons.link),
                    onPressed: _openUrl,
                  )
                : null,
            hoverColor: _grey,
            onTap: () {
              _showCommentDialog(context);
            },
          ),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              final reminders = state.remindersByTask[widget.task.id] ?? [];
              final hasReminders = reminders.isNotEmpty;

              return ListTile(
                leading: Icon(Icons.timer),
                title: Text(AppLocalizations.of(context)!.reminder),
                subtitle: Text(hasReminders
                    ? 'has ${reminders.length} reminders'
                    : AppLocalizations.of(context)!.noReminder),
                hoverColor: _grey,
                onTap: () {
                  context
                      .read<ReminderBloc>()
                      .add(LoadRemindersForTask(widget.task.id!));
                  if (!hasReminders) {
                    context.push("/reminder/create",
                        extra: {"taskId": widget.task.id});
                  } else {
                    _showRemindersBottomSheet(context);
                  }
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.attachment),
            title: Text(AppLocalizations.of(context)!.manageResources),
            subtitle: Text('Attach images to this task'),
            hoverColor: _grey,
            onTap: () {
              context.push('/resource/edit?taskId=${widget.task.id}');
            },
          ),
          _buildResourcesThumbnail(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(EditTaskKeys.Edit_TASK),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              context.read<TaskBloc>().add(UpdateTaskEvent(
                  task: Task.update(
                    id: widget.task.id,
                    title: _titleController.text,
                    projectId: selectedProject.id ?? 0,
                    priority: selectedPriority,
                    dueDate: selectedDueDate,
                    comment: _commentController.text,
                  ),
                  labelIds: labelIds));

              /// if update task success
              final filter = context.read<HomeBloc>().state.filter;
              context.read<TaskBloc>().add(FilterTasksEvent(filter: filter!));

              if (context.isWiderScreen()) {
                context
                    .read<HomeBloc>()
                    .add(ApplyFilterEvent("Today", Filter.byToday()));
              } else {
                context.safePop();
              }
            }
          }),
    );
  }

  BlocBuilder<ResourceBloc, ResourceState> _buildResourcesThumbnail() {
    return BlocBuilder<ResourceBloc, ResourceState>(
      builder: (context, state) {
        if (state is ResourceLoaded && state.resources.isNotEmpty) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resources (${state.resources.length})',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 80.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.resources.length,
                    itemBuilder: (context, index) {
                      final resource = state.resources[index];
                      return GestureDetector(
                        onTap: () {
                          context
                              .push('/resource/edit?taskId=${widget.task.id}');
                        },
                        child: Container(
                          width: 80.0,
                          height: 80.0,
                          margin: EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: File(resource.path).existsSync()
                                ? Image.file(
                                    File(resource.path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey[400],
                                          size: 32.0,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 32.0,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showRemindersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _RemindersBottomSheet(taskId: widget.task.id!);
      },
    );
  }

  Color? get _grey => Colors.grey[300];

  Future<Null> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDueDate = picked.millisecondsSinceEpoch;
      });
    }
  }

  Future<PriorityStatus?> _showPriorityDialog(BuildContext context) async {
    return await showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context)!.selectPriority),
            children: <Widget>[
              buildContainer(context, PriorityStatus.PRIORITY_1),
              buildContainer(context, PriorityStatus.PRIORITY_2),
              buildContainer(context, PriorityStatus.PRIORITY_3),
              buildContainer(context, PriorityStatus.PRIORITY_4),
            ],
          );
        });
  }

  Future<PriorityStatus?> _showProjectsDialog(BuildContext context) async {
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext dialogContext) {
          return BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context)!.selectProject),
                children: buildProjects(context,
                    state.projectsWithCount.map((p) => p.trimCount()).toList()),
              );
            },
          );
        });
  }

  Future<PriorityStatus?> _showLabelsDialog(BuildContext context) async {
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext context) {
          return BlocBuilder<LabelBloc, LabelState>(
            builder: (context, state) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context)!.selectLabels),
                children: buildLabels(context, state.labels),
              );
            },
          );
        });
  }

  Future<void> _showCommentDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          title: Text(AppLocalizations.of(context)!.comments),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.comments,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openUrl() async {
    final url = detectedUrl;
    if (url != null) {
      try {
        await launchURL(url);
      } catch (e) {
        showSnackbar(context, 'Could not launch $url');
      }
    }
  }

  List<Widget> buildProjects(
    BuildContext context,
    List<Project> projectList,
  ) {
    List<Widget> projects = projectList
        .map((Project project) => ListTile(
              leading: Container(
                width: 12.0,
                height: 12.0,
                child: CircleAvatar(
                  backgroundColor: Color(project.colorValue),
                ),
              ),
              title: Text(project.name),
              onTap: () {
                setState(() {
                  selectedProject = project;
                  Navigator.pop(context);
                });
              },
            ))
        .toList();
    return projects;
  }

  List<Widget> buildLabels(
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = labelList
        .map((Label label) => ListTile(
              leading:
                  Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
              title: Text(label.name),
              trailing: selectedLabels.contains(label)
                  ? Icon(Icons.close)
                  : Container(width: 18.0, height: 18.0),
              onTap: () {
                setState(() {
                  if (selectedLabels.contains(label)) {
                    selectedLabels.remove(label);
                  } else {
                    selectedLabels.add(label);
                  }
                });
                Navigator.pop(context);
              },
            ))
        .toList();
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, PriorityStatus status) {
    return GestureDetector(
        onTap: () {
          setState(() {
            selectedPriority = status;
            Navigator.pop(context, status);
          });
        },
        child: Container(
            color: status == selectedPriority ? Colors.grey : Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 6.0,
                    color: priorityColor[status.index],
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text(priorityText[status.index],
                    style: TextStyle(fontSize: 18.0)),
              ),
            )));
  }
}

class _TaskInputForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final String? Function(String?) validator;
  final String titleKey;

  const _TaskInputForm({
    required this.formKey,
    required this.titleController,
    required this.validator,
    required this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: ValueKey(titleKey),
          validator: validator,
          controller: titleController,
          onSaved: (value) {},
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "",
            labelText: AppLocalizations.of(context)!.taskTitle,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ),
    );
  }
}

class EditTaskProvider extends StatelessWidget {
  final Task? task;

  EditTaskProvider({this.task});

  @override
  Widget build(BuildContext context) {
    return EditTaskScreen(
      task: task!,
    );
  }
}

class _RemindersBottomSheet extends StatelessWidget {
  final int taskId;

  const _RemindersBottomSheet({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final reminders = state.remindersByTask[taskId] ?? [];

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return Dismissible(
                    key: Key(
                        'reminder_${reminder.id}_${reminder.remindTime?.millisecondsSinceEpoch ?? 0}'),
                    // Unique key for Dismissible
                    direction: DismissDirection.startToEnd,
                    // Swipe from right to left
                    background: Container(
                      color: Colors.red,
                      // Red background when swiping
                      alignment: Alignment.centerRight,
                      // Align content to the right
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        // Make the Row size just big enough for its children
                        children: <Widget>[
                          Text(
                            // Use reminder ID and time string
                            '提醒 #${reminder.id} (${reminder.remindTime.toString()})',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.0),
                          // Spacing between icon and text
                          Icon(Icons.delete, color: Colors.white),
                          // Delete icon
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      // Show confirmation dialog before dismissing
                      return await showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('确认删除'),
                            content: const Text('您确定要删除此提醒吗？'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('删除'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      // Dispatch the remove event after dismissal is confirmed
                      context
                          .read<ReminderBloc>()
                          .add(RemoveReminderEvent(reminder.id!));

                      // Optionally show a Snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('提醒 ${reminder.id} 已删除')),
                      );
                    },
                    child: ListTile(
                      title: Text('Reminder #${reminder.id}'),
                      subtitle: Text(reminder.remindTime.toString()),
                      trailing: Checkbox(
                        value: reminder.enable,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            // Create an updated reminder object with toggled enable state
                            final updatedReminder = Reminder.update(
                              id: reminder.id,
                              type: reminder.type,
                              remindTime: reminder.remindTime,
                              enable: newValue,
                              // Use the new value
                              taskId: reminder.taskId,
                            );
                            // Dispatch the update event to the ReminderBloc
                            context
                                .read<ReminderBloc>()
                                .add(UpdateReminderEvent(updatedReminder));
                          }
                        },
                      ),
                      onTap: () {
                        // Navigate to the update page for the reminder
                        context.push("/reminder/update", extra: reminder);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the create reminder page for the current task
                  context.push("/reminder/create", extra: {"taskId": taskId});
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.blue; // Color when hovered
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.blue; // Color when pressed
                      }
                      return Theme.of(context)
                          .colorScheme
                          .onInverseSurface; // Default color
                    },
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  // To keep content centered
                  children: <Widget>[
                    Text("Add Reminder"),
                    SizedBox(width: 8),
                    // Add some spacing between text and icon
                    Icon(Icons.add),
                    // Replace with your desired icon
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
