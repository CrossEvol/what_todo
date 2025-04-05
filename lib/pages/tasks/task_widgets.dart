import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (BuildContext context, TaskState state) {
        if (state is TaskReOrdered ||
            state is TaskHasDeleted ||
            state is TaskHasUpdated) {
          final filter = context.read<HomeBloc>().state.filter;
          context.read<TaskBloc>().add(FilterTasksEvent(filter: filter!));
        }
      },
      builder: (context, state) {
        if (state is TaskLoaded) {
          return _buildTaskList(state.tasks, context);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTaskList(List<Task> list, BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color draggableItemColor = colorScheme.tertiary;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: draggableItemColor,
            shadowColor: draggableItemColor,
            child: child,
          );
        },
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget(AppLocalizations.of(context)!.noTaskAdded)
          : Container(
              child: ReorderableListView.builder(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  return ClipRect(
                    key: ValueKey('${list[index].id}'),
                    child: Dismissible(
                        key: ValueKey("swipe_${list[index].id}_$index"),
                        onDismissed: (DismissDirection direction) {
                          var taskID = list[index].id!;
                          String message =
                              direction == DismissDirection.endToStart
                                  ? AppLocalizations.of(context)!.taskCompleted
                                  : AppLocalizations.of(context)!.taskDeleted;
                          if (direction == DismissDirection.endToStart) {
                            context.read<TaskBloc>().add(UpdateTaskStatusEvent(
                                taskID, TaskStatus.COMPLETE));
                          } else {
                            context
                                .read<TaskBloc>()
                                .add(DeleteTaskEvent(taskID));
                            context.read<HomeBloc>().add(LoadTodayCountEvent());
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                            backgroundColor:
                                direction == DismissDirection.endToStart
                                    ? Colors.green
                                    : Colors.red,
                          ));
                        },
                        background: Container(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment(-0.95, 0.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.green,
                          child: Align(
                            alignment: Alignment(0.95, 0.0),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                        child: TaskRow(list[index])),
                  );
                },
                proxyDecorator: proxyDecorator,
                onReorder: (int oldIndex, int newIndex) {
                  var oldTask = list[oldIndex];
                  var newTask = list[
                      newIndex == list.length ? list.length - 1 : newIndex];
                  context.read<TaskBloc>().add(
                      ReOrderTasksEvent(oldTask: oldTask, newTask: newTask));
                },
              ),
            ),
    );
  }
}
