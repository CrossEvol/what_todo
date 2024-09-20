import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/home/home_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/bloc/edit_task_bloc.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';

import 'bloc/task_bloc.dart';
import 'models/task.dart';

class EditTaskScreen extends StatelessWidget {
  final Task? task;

  EditTaskScreen({this.task});

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    EditTaskBloc editTaskBloc = BlocProvider.of<EditTaskBloc>(context);
    editTaskBloc.taskID = task!.id!;
    editTaskBloc.updateTitle = task?.title ?? '';
    editTaskBloc
        .updateDueDate(task?.dueDate ?? DateTime.now().millisecondsSinceEpoch);
    editTaskBloc.updatePriority(task?.priority ?? PriorityStatus.PRIORITY_4);
    editTaskBloc.projectSelectedByID(task!.projectId);
    editTaskBloc.labelAddByNames(task?.labelList ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Task",
          key: ValueKey(EditTaskKeys.Edit_TASK_TITLE),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: task?.title ?? '',
                key: ValueKey(EditTaskKeys.Edit_TITLE),
                validator: (value) {
                  var msg = value!.isEmpty ? "Title Cannot be Empty" : null;
                  return msg;
                },
                onSaved: (value) {
                  editTaskBloc.updateTitle = value!;
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
            key: ValueKey("editProject"),
            leading: Icon(Icons.book),
            title: Text("Project"),
            subtitle: StreamBuilder<Project>(
              stream: editTaskBloc.selectedProject,
              initialData: Project.getInbox(),
              builder: (context, snapshot) => Text(snapshot.data!.name),
            ),
            hoverColor: _grey,
            onTap: () {
              _showProjectsDialog(editTaskBloc, context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Due Date"),
            subtitle: StreamBuilder<int>(
              stream: editTaskBloc.dueDateSelected,
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
              stream: editTaskBloc.prioritySelection,
              initialData: PriorityStatus.PRIORITY_4,
              builder: (context, snapshot) =>
                  Text(priorityText[snapshot.data!.index]),
            ),
            hoverColor: _grey,
            onTap: () {
              _showPriorityDialog(editTaskBloc, context);
            },
          ),
          ListTile(
              leading: Icon(Icons.label),
              title: Text("Labels"),
              subtitle: StreamBuilder<String>(
                stream: editTaskBloc.labelSelection,
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
          key: ValueKey(EditTaskKeys.Edit_TASK),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (_formState.currentState!.validate()) {
              _formState.currentState!.save();
              editTaskBloc.updateTask().listen((value) async {
                if (context.isWiderScreen()) {
                  context
                      .bloc<HomeBloc>()
                      .applyFilter("Today", Filter.byToday());
                } else {
                  /*TODO did not find the better way to refresh data */
                  await Navigator.push(
                    context,
                    MaterialPageRoute<bool>(
                        builder: (context) => BlocProvider(
                              bloc: HomeBloc(),
                              child: AdaptiveHome(),
                            )),
                  );
                  // context.safePop();
                }
              });
            }
          }),
    );
  }

  Color? get _grey => Colors.grey[300];

  Future<Null> _showDatePicker(BuildContext context) async {
    EditTaskBloc editTaskBloc = BlocProvider.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      editTaskBloc.updateDueDate(picked.millisecondsSinceEpoch);
    }
  }

  Future<PriorityStatus?> _showPriorityDialog(
      EditTaskBloc editTaskBloc, BuildContext context) async {
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
      EditTaskBloc editTaskBloc, BuildContext context) async {
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<List<Project>>(
              stream: editTaskBloc.projects,
              initialData: <Project>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Project'),
                  children:
                      buildProjects(editTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  Future<PriorityStatus?> _showLabelsDialog(BuildContext context) async {
    EditTaskBloc editTaskBloc = BlocProvider.of(context);
    return showDialog<PriorityStatus>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<Label>>(
              stream: editTaskBloc.labels,
              initialData: <Label>[],
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: const Text('Select Labels'),
                  children: buildLabels(editTaskBloc, context, snapshot.data!),
                );
              });
        });
  }

  List<Widget> buildProjects(
    EditTaskBloc editTaskBloc,
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
                editTaskBloc.projectSelected(project);
                Navigator.pop(context);
              },
            ))
        .toList();
    return projects;
  }

  List<Widget> buildLabels(
    EditTaskBloc editTaskBloc,
    BuildContext context,
    List<Label> labelList,
  ) {
    List<Widget> labels = labelList
        .map((Label label) => ListTile(
              leading:
                  Icon(Icons.label, color: Color(label.colorValue), size: 18.0),
              title: Text(label.name),
              trailing: editTaskBloc.selectedLabels.contains(label)
                  ? Icon(Icons.close)
                  : Container(width: 18.0, height: 18.0),
              onTap: () {
                editTaskBloc.labelAddOrRemove(label);
                Navigator.pop(context);
              },
            ))
        .toList();
    return labels;
  }

  GestureDetector buildContainer(BuildContext context, PriorityStatus status) {
    EditTaskBloc editTaskBloc = BlocProvider.of(context);
    return GestureDetector(
        onTap: () {
          editTaskBloc.updatePriority(status);
          Navigator.pop(context, status);
        },
        child: Container(
            color: status == editTaskBloc.lastPrioritySelection
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

class EditTaskProvider extends StatelessWidget {
  final Task? task;

  EditTaskProvider({this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: EditTaskBloc(
        TaskDB.get(),
        ProjectDB.get(),
        LabelDB.get(),
      ),
      child: EditTaskScreen(
        task: task,
      ),
    );
  }
}
