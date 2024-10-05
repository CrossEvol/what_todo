import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/row_task.dart';
import 'package:flutter_app/utils/app_util.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TaskBloc _tasksBloc = CustomBlocProvider.of(context);
    return StreamBuilder<List<Task>>(
      stream: _tasksBloc.tasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTaskList(snapshot.data!);
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
                            final TaskBloc taskBloc =
                                CustomBlocProvider.of<TaskBloc>(context);
                            String message =
                                direction == DismissDirection.endToStart
                                    ? "Task completed"
                                    : "Task deleted";
                            if (direction == DismissDirection.endToStart) {
                              taskBloc.updateStatus(
                                  taskID, TaskStatus.COMPLETE);
                            } else {
                              taskBloc.delete(taskID);
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
