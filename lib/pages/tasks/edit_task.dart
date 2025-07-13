import 'package:flutter_app/dao/reminder_db.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
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
        .read<AdminBloc>()
        .state
        .projects
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
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey(EditTaskKeys.Edit_TITLE),
                validator: (value) {
                  return value!.isEmpty
                      ? AppLocalizations.of(context)!.titleCannotBeEmpty
                      : null;
                },
                controller: _titleController,
                onSaved: (value) {},
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "",
                  labelText: AppLocalizations.of(context)!.taskTitle,
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
            ),
            key: _formState,
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
          ListTile(
            leading: Icon(Icons.timer),
            title: Text(AppLocalizations.of(context)!.reminder),
            subtitle: Text(AppLocalizations.of(context)!.noReminder),
            hoverColor: _grey,
            onTap: () async {
              final reminders =
                  await ReminderDB.get().getRemindersForTask(widget.task.id!);
              if (reminders.isEmpty) {
                context.push("/reminder/create",
                    extra: {"taskId": widget.task.id});
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: reminders.length,
                            itemBuilder: (context, index) {
                              final reminder = reminders[index];
                              return ListTile(
                                title: Text('Reminder #${reminder.id}'),
                                subtitle: Text(reminder.remindTime.toString()),
                                trailing: Checkbox(
                                    value: reminder.enable, onChanged: (_) {}),
                                onTap: () {
                                  context.push("/reminder/update",
                                      extra: reminder);
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push("/reminder/create",
                                  extra: {"taskId": widget.task.id});
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.blue; // Color when hovered
                                  }
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.blue; // Color when hovered
                                  }
                                  return Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface; // Default color
                                },
                              ),
                            ),
                            child: Row(
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
            },
          )
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
          return BlocBuilder<AdminBloc, AdminState>(
            builder: (context, state) {
              return SimpleDialog(
                title: Text(AppLocalizations.of(context)!.selectProject),
                children: buildProjects(
                    context, state.projects.map((p) => p.trimCount()).toList()),
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
          title: Text(AppLocalizations.of(context)!.comments),
          content: TextField(
            controller: _commentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.comments,
              border: OutlineInputBorder(),
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
