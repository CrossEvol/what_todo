// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/dismissible_example.dart'
    as _widgetbook_workspace_dismissible_example;
import 'package:widgetbook_workspace/page_storage_example.dart'
    as _widgetbook_workspace_page_storage_example;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'demo',
    children: [
      _widgetbook.WidgetbookLeafComponent(
        name: 'DismissibleExample',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder:
              _widgetbook_workspace_dismissible_example.buildCoolButtonUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'PageStorageExample',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder:
              _widgetbook_workspace_page_storage_example.buildCoolButtonUseCase,
        ),
      ),
    ],
  ),
];
