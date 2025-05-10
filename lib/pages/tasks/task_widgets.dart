import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/pages/tasks/task_completed/row_task_completed.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

import 'bloc/filter.dart';

class TasksPage extends StatelessWidget {
  final ScrollController? scrollController;

  const TasksPage({Key? key, this.scrollController}) : super(key: key);

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
        final homeBloc = context.read<HomeBloc>();
        final undone = homeBloc.state.showPendingTasks;
        if (state is TaskLoaded) {
          return _buildTaskList(context, state.tasks, undone);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks, bool undone) {
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
      child: tasks.isEmpty
          ? MessageInCenterWidget(AppLocalizations.of(context)!.noTaskAdded)
          : Container(
              child: ReorderableListView.builder(
                scrollController: scrollController,
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  var task = tasks[index];

                  return ClipRect(
                    key: ValueKey('${task.id}'),
                    child: undone
                        ? PendingTaskListItem(
                            task: task,
                            index: index,
                          )
                        : CompletedTaskListItem(
                            task: task,
                            index: index,
                          ),
                  );
                },
                proxyDecorator: proxyDecorator,
                onReorder: (int oldIndex, int newIndex) {
                  var oldTask = tasks[oldIndex];
                  var newTask = tasks[
                      newIndex == tasks.length ? tasks.length - 1 : newIndex];
                  context.read<TaskBloc>().add(
                      ReOrderTasksEvent(oldTask: oldTask, newTask: newTask));
                },
              ),
            ),
    );
  }
}

class CompletedTaskListItem extends StatelessWidget {
  const CompletedTaskListItem({
    super.key,
    required this.task,
    required this.index,
  });

  final Task task;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey("swipe_completed_${task.id}_$index"),
        direction: DismissDirection.endToStart,
        background: Container(),
        onDismissed: (DismissDirection directions) {
          if (directions == DismissDirection.endToStart) {
            final taskID = task.id!;
            context
                .read<TaskBloc>()
                .add(UpdateTaskStatusEvent(taskID, TaskStatus.PENDING));
            context.read<TaskBloc>().add(
                FilterTasksEvent(filter: Filter.byStatus(TaskStatus.COMPLETE)));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Task Undo")));
          }
        },
        secondaryBackground: Container(
          color: Colors.grey[500],
          child: Align(
            alignment: Alignment(0.95, 0.0),
            child: Text("UNDO",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        child: TaskCompletedRow(task));
  }
}

class PendingTaskListItem extends StatelessWidget {
  const PendingTaskListItem({
    super.key,
    required this.task,
    required this.index,
  });

  final Task task;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey("swipe_${task.id}_$index"),
        onDismissed: (DismissDirection direction) {
          var taskID = task.id!;
          String message = direction == DismissDirection.endToStart
              ? AppLocalizations.of(context)!.taskCompleted
              : AppLocalizations.of(context)!.taskDeleted;
          if (direction == DismissDirection.endToStart) {
            context
                .read<TaskBloc>()
                .add(UpdateTaskStatusEvent(taskID, TaskStatus.COMPLETE));
          } else {
            context.read<TaskBloc>().add(DeleteTaskEvent(taskID));
            context.read<HomeBloc>().add(LoadTodayCountEvent());
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: direction == DismissDirection.endToStart
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
        child: TaskRow(task));
  }
}
