import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/task_uncompleted/row_task_uncompleted.dart';

class TaskUnCompletedPage extends StatelessWidget {
  final TaskBloc _taskBloc = TaskBloc(TaskDB.get());

  @override
  Widget build(BuildContext context) {
    _taskBloc.filterByStatus(TaskStatus.PENDING);
    return BlocProvider(
      bloc: _taskBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Task Uncompleted"),
        ),
        body: StreamBuilder<List<Tasks>>(
            stream: _taskBloc.tasks,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ClipRect(
                        child: Dismissible(
                            key: ValueKey(
                                "swipe_uncompleted_${snapshot.data![index].id}_$index"),
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
                                final taskID = snapshot.data![index].id!;
                                _taskBloc.updateStatus(
                                    taskID, TaskStatus.COMPLETE);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Task Complete")));
                              }
                            },
                            child: TaskUncompletedRow(snapshot.data![index])),
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
