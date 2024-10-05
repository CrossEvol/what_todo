import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/constants/app_constant.dart';
import 'package:go_router/go_router.dart';

import 'task_db.dart';

class TaskRow extends StatelessWidget {
  final MyTaskBloc _taskBloc = MyTaskBloc(TaskDB.get());
  final Task task;
  static final dateLabel = "Date";
  final List<String> labelNames = [];

  TaskRow(this.task);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.go('/task/edit', extra: this.task);
        _taskBloc.refresh();
      },
      child: Column(
        children: <Widget>[
          Container(
            key: ValueKey("taskPriority_${task.id}"),
            margin: const EdgeInsets.symmetric(vertical: PADDING_TINY),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 4.0,
                  color: priorityColor[task.priority.index],
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PADDING_SMALL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: PADDING_SMALL,
                      bottom: PADDING_VERY_SMALL,
                    ),
                    child: Text(
                      task.title,
                      key: ValueKey("taskTitle_${task.id}"),
                      style: TextStyle(
                        fontSize: FONT_SIZE_TITLE,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  getLabels(task.labelList),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Row(
                      children: <Widget>[
                        Text(
                          getFormattedDate(task.dueDate),
                          style: TextStyle(
                              color: Colors.grey, fontSize: FONT_SIZE_DATE),
                          key: ValueKey("taskDueDate_${task.id}"),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(task.projectName!,
                                      key: ValueKey(
                                          "taskProjectName_${task.id}"),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: FONT_SIZE_LABEL)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    width: 8.0,
                                    height: 8.0,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Color(task.projectColor!),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getLabels(List<String> labelList) {
    if (labelList.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(
            left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
        child: Text(task.labelList.join("  "),
            key: ValueKey("taskLabels_${task.id}"),
            style: TextStyle(fontSize: FONT_SIZE_LABEL)),
      );
    }
  }
}
