import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import the widget from your app
import 'package:flutter_app/demo/dismissible_example.dart';

@widgetbook.UseCase(name: 'Default', type: DismissibleExample)
Widget buildCoolButtonUseCase(BuildContext context) {
  return DismissibleExample();
}
