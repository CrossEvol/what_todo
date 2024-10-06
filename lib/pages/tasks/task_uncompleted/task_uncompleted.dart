import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/row_task_uncompleted.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskUnCompletedPage extends StatelessWidget {
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
          title: Text("Task Uncompleted"),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
          if (state is TaskLoaded) {
            var tasks = state.tasks;
            return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ClipRect(
                    child: Dismissible(
                        key: ValueKey(
                            "swipe_uncompleted_${tasks[index].id}_$index"),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: Colors.green,
                          child: Align(
                            alignment: Alignment(-0.95, 0.0),
                            child: Text("COMPLETE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        secondaryBackground: Container(),
                        onDismissed: (DismissDirection directions) {
                          if (directions == DismissDirection.startToEnd) {
                            final taskID = tasks[index].id!;
                            context.read<TaskBloc>().add(UpdateTaskStatusEvent(
                                taskID, TaskStatus.COMPLETE));
                            context.read<TaskBloc>().add(FilterTasksEvent(
                                filter: Filter.byStatus(TaskStatus.PENDING)));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Task Complete")));
                          }
                        },
                        child: TaskUncompletedRow(tasks[index])),
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
