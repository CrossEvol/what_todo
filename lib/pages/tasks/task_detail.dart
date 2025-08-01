import 'package:flutter/material.dart';

// MyHomePage is also a StatelessWidget for this simple example.
// It represents the main page of our app.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides a framework that implements the basic material design
    // visual layout structure. It provides an app bar, a body, and a floating
    // action button.
    return Scaffold(
      appBar: AppBar(
        // An AppBar is a horizontal bar at the top of the app.
        title: const Text('My First Flutter Page'),
      ),
      // The body of the Scaffold is where the main content of the screen goes.
      body: Center(
        // The Center widget centers its child within itself.
        child: Column(
          // Column lays out its children in a vertical array.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Hello, Flutter!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Adds some space between widgets.
            ElevatedButton(
              onPressed: () {
                // This function is called when the button is pressed.
                // In a real app, you might navigate to a new page or update the UI.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Button Pressed!'),
                  ),
                );
              },
              child: const Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
