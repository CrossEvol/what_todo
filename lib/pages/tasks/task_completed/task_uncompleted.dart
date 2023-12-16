import 'package:flutter/material.dart';

class TaskUnCompletedPage extends StatelessWidget {
  const TaskUnCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: const Text('Uncompleted'),
      ),
    );
  }
}
