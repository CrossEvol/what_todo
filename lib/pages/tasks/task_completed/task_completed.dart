import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_completed/row_task_completed.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCompletedPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          context
              .read<TaskBloc>()
              .add(FilterTasksEvent(filter: Filter.byToday()));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Task Completed"),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
          if (state is TaskLoaded) {
            var tasks = state.tasks;
            return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ClipRect(
                    child: Dismissible(
                        key: ValueKey(
                            "swipe_completed_${tasks[index].id}_$index"),
                        direction: DismissDirection.endToStart,
                        background: Container(),
                        onDismissed: (DismissDirection directions) {
                          if (directions == DismissDirection.endToStart) {
                            final taskID = tasks[index].id!;
                            context.read<TaskBloc>().add(UpdateTaskStatusEvent(
                                taskID, TaskStatus.PENDING));
                            context.read<TaskBloc>().add(FilterTasksEvent(
                                filter: Filter.byStatus(TaskStatus.COMPLETE)));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Task Undo")));
                          }
                        },
                        secondaryBackground: Container(
                          color: Colors.grey[500],
                          child: Align(
                            alignment: Alignment(0.95, 0.0),
                            child: Text("UNDO",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        child: TaskCompletedRow(tasks[index])),
                  );
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
