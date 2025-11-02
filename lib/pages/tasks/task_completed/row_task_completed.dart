import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/date_util.dart';
import 'package:flutter_app/constants/app_constant.dart';
import 'package:go_router/go_router.dart';

import '../../labels/label.dart';

class TaskCompletedRow extends StatelessWidget {
  final Task task;
  static final dateLabel = "Date";

  TaskCompletedRow(this.task);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/task/${this.task.id}/edit', extra: this.task);
      },
      child: Column(
        children: <Widget>[
          Container(
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
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Text(task.title,
                        key: ValueKey("task_completed_${task.id}"),
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: FONT_SIZE_TITLE,
                            fontWeight: FontWeight.bold)),
                  ),
                  CompletedTaskLabels(task.labelList),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Row(
                      children: <Widget>[
                        Text(
                          getFormattedDate(task.dueDate),
                          style: TextStyle(
                              color: Colors.grey, fontSize: FONT_SIZE_DATE),
                          key: Key(dateLabel),
                        ),
                        if (task.resources.isNotEmpty) ...[
                          SizedBox(width: 8.0),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link,
                                size: FONT_SIZE_DATE,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2.0),
                              Text(
                                '${task.resources.length}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: FONT_SIZE_DATE,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(task.projectName!,
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
}

class CompletedTaskLabels extends StatelessWidget {
  final List<Label> labelList;

  const CompletedTaskLabels(this.labelList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (labelList.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(
            left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
        child: Wrap(
          spacing: 8.0, // Horizontal space between labels
          runSpacing: 4.0, // Vertical space between lines of labels
          children: labelList.map((label) {
            return Row(
              mainAxisSize: MainAxisSize.min, // Row takes minimum space
              children: <Widget>[
                Text(
                  label.name, // Access label name
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: FONT_SIZE_LABEL),
                ),
                SizedBox(width: 4.0), // Space between text and icon
                Icon(
                  Icons.label_off_rounded,
                  size: FONT_SIZE_LABEL, // Match icon size with text size
                  color: Color(label.colorValue), // Use label color
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
  }
}
