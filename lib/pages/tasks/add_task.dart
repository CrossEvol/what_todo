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
import 'package:flutter_app/utils/app_util.dart' show showSnackbar;
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  _AddTaskScreenState();

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  PriorityStatus selectedPriority = PriorityStatus.PRIORITY_4;
  PriorityStatus lastPrioritySelection = PriorityStatus.PRIORITY_4;
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.addTask,
          key: ValueKey(AddTaskKeys.ADD_TASK_TITLE),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey(AddTaskKeys.ADD_TITLE),
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
            key: ValueKey("addProject"),
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
            onTap: () {
              showSnackbar(context, AppLocalizations.of(context)!.comingSoon);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          key: ValueKey(AddTaskKeys.ADD_TASK),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              context.read<TaskBloc>().add(AddTaskEvent(
                  task: Task.create(
                    title: _titleController.text,
                    projectId: selectedProject.id ?? 0,
                    priority: selectedPriority,
                    comment: _commentController.text,
                  ),
                  labelIds: labelIds));

              /// if add task success
              context.read<HomeBloc>().add(LoadTodayCountEvent());
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
            lastPrioritySelection = selectedPriority;
            selectedPriority = status;
            Navigator.pop(context, status);
          });
        },
        child: Container(
            color: status == lastPrioritySelection ? Colors.grey : Colors.white,
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

class AddTaskProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddTaskScreen();
  }
}
