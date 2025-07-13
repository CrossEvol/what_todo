import 'package:flutter/material.dart';

class ReminderUpdatePage extends StatefulWidget {
  const ReminderUpdatePage({super.key});

  @override
  State<ReminderUpdatePage> createState() => _ReminderUpdatePageState();
}

class _ReminderUpdatePageState extends State<ReminderUpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Reminder"),
      ),
      body: const Center(
        child: Text("Reminder Update Page"),
      ),
    );
  }
}
