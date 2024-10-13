import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoaded) {
          return _buildTaskList(state.tasks);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTaskList(List<Task> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: list.length == 0
          ? MessageInCenterWidget("No Task Added")
          : Container(
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRect(
                      child: Dismissible(
                          key: ValueKey("swipe_${list[index].id}_$index"),
                          onDismissed: (DismissDirection direction) {
                            var taskID = list[index].id!;
                            String message =
                                direction == DismissDirection.endToStart
                                    ? "Task completed"
                                    : "Task deleted";
                            if (direction == DismissDirection.endToStart) {
                              context.read<TaskBloc>().add(
                                  UpdateTaskStatusEvent(
                                      taskID, TaskStatus.COMPLETE));
                            } else {
                              context
                                  .read<TaskBloc>()
                                  .add(DeleteTaskEvent(taskID));
                              context
                                  .read<HomeBloc>()
                                  .add(LoadTodayCountEvent());
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
                  }),
            ),
    );
  }
}
