import 'package:flutter/material.dart';

class ReminderCreatePage extends StatefulWidget {
  const ReminderCreatePage({super.key});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Reminder"),
      ),
      body: const Center(
        child: Text("Reminder Create Page"),
      ),
    );
  }
}
