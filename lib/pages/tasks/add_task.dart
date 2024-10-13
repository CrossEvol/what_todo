import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/bloc/my_add_task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTaskScreen extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    MyAddTaskBloc createTaskBloc = CustomBlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Task",
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
                  var msg = value!.isEmpty ? "Title Cannot be Empty" : null;
                  return msg;
                },
                onSaved: (value) {
                  createTaskBloc.updateTitle = value!;
                },
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "",
                  labelText: "Title",
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
            title: Text("Project"),
            subtitle: StreamBuilder<Project>(
              stream: createTaskBloc.selectedProject,
              initialData: Project.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data!.name),
            ),
            hoverColor: _grey,
            onTap: () {
              _showProjectsDialog(createTaskBloc, context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Due Date"),
            subtitle: StreamBuilder<int>(
              stream: createTaskBloc.dueDateSelected,
              initialData: DateTime.now().millisecondsSinceEpoch,
              builder: (context, snapshot) =>
                  Text(getFormattedDate(snapshot.data!)),
            ),
            hoverColor: _grey,
            onTap: () {
              _showDatePicker(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text("Priority"),
            subtitle: StreamBuilder<PriorityStatus>(
              stream: createTaskBloc.prioritySelection,
              initialData: PriorityStatus.PRIORITY_4,
              builder: (context, snapshot) =>
                  Text(priorityText[snapshot.data!.index]),
            ),
            hoverColor: _grey,
            onTap: () {
              _showPriorityDialog(createTaskBloc, context);
            },
          ),
          ListTile(
              leading: Icon(Icons.label),
              title: Text("Labels"),
              subtitle: StreamBuilder<String>(
                stream: createTaskBloc.labelSelection,
                initialData: "No Labels",
                builder: (context, snapshot) => Text(snapshot.data!),
              ),
              hoverColor: _grey,
              onTap: () {
                _showLabelsDialog(context);
              }),
          ListTile(
            leading: Icon(Icons.mode_comment),
            title: Text("Comments"),
            subtitle: Text("No Comments"),
            hoverColor: _grey,
            onTap: () {
              showSnackbar(context, "Coming Soon");
            },
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text("Reminder"),
            subtitle: Text("No Reminder"),
            hoverColor: _grey,
            onTap: () {
              showSnackbar(context, "Coming Soon");
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
              createTaskBloc.createTask().listen((value) {
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
              });
            }
          }),
    );
  }

  Color? get _grey => Colors.grey[300];

  Future<Null> _showDatePicker(BuildContext context) async {
    MyAddTaskBloc createTaskBloc = CustomBlocProvider.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      createTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }

  Future<PriorityStatus?> _showPriorityDialog(
      MyAddTaskBloc createTaskBloc, BuildContext context) async {
    return await showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext dialogContext) {
          return SimpleDialog(
            title: const Text('Select Priority'),
            children: <Widget>[
              buildContainer(context, PriorityStatus.PRIORITY_1),
              buildContainer(context, PriorityStatus.PRIORITY_2),
              buildContainer(context, PriorityStatus.PRIORITY_3),
              buildContainer(context, PriorityStatus.PRIORITY_4),
            ],
          );
        });
  }

  Future<PriorityStatus?> _showProjectsDialog(
      MyAddTaskBloc createTaskBloc, BuildContext context) async {
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<List<Project>>(
              stream: createTaskBloc.projects,
              initialData: <Project>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Project'),
                  children:
                      buildProjects(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  Future<PriorityStatus?> _showLabelsDialog(BuildContext context) async {
    MyAddTaskBloc createTaskBloc = CustomBlocProvider.of(context);
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<Label>>(
              stream: createTaskBloc.labels,
              initialData: <Label>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Labels'),
                  children:
                      buildLabels(createTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  List<Widget> buildProjects(
    MyAddTaskBloc createTaskBloc,
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
                createTaskBloc.projectSelected(project);
                Navigator.pop(context);
              },
            ))
        .toList();
    return projects;
  }

  List<Widget> buildLabels(
    MyAddTaskBloc createTaskBloc,
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = labelList
        .map((Label label) => ListTile(
              leading:
                  Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
              title: Text(label.name),
              trailing: createTaskBloc.selectedLabels.contains(label)
                  ? Icon(Icons.close)
                  : Container(width: 18.0, height: 18.0),
              onTap: () {
                createTaskBloc.labelAddOrRemove(label);
                Navigator.pop(context);
              },
            ))
        .toList();
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, PriorityStatus status) {
    MyAddTaskBloc createTaskBloc = CustomBlocProvider.of(context);
    return GestureDetector(
        onTap: () {
          createTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == createTaskBloc.lastPrioritySelection
                ? Colors.grey
                : Colors.white,
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
    return CustomBlocProvider(
      bloc: MyAddTaskBloc(TaskDB.get(), ProjectDB.get(), LabelDB.get()),
      child: AddTaskScreen(),
    );
  }
}
