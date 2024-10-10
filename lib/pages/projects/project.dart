import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Project {
  static final tblProject = "project";
  static final dbId = "id";
  static final dbName = "name";
  static final dbColorCode = "colorCode";
  static final dbColorName = "colorName";

  int? id;
  late int colorValue;
  late String name;
  late String colorName;

  Project.create(this.name, this.colorValue, this.colorName);

  Project.update({required this.id, name, colorCode = "", colorName = ""}) {
    if (name != "") {
      this.name = name;
    }
    if (colorCode != "") {
      this.colorValue = colorCode;
    }
    if (colorName != "") {
      this.colorName = colorName;
    }
  }

  Project.getInbox()
      : this.update(
            id: 1,
            name: "Inbox",
            colorName: "Grey",
            colorCode: Colors.grey.value);

  Project.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId],
            name: map[dbName],
            colorCode: map[dbColorCode],
            colorName: map[dbColorName]);

  Map<String, dynamic> toMap() {
    return {
      Project.dbId: id,
      Project.dbName: name,
      Project.dbColorCode: colorValue,
      Project.dbColorName: colorName,
    };
  }
}

class ProjectWithCount {
  final int id;
  final String name;
  final int colorCode;
  final String colorName;
  final int count;

  const ProjectWithCount({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.colorName,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'colorCode': this.colorCode,
      'colorName': this.colorName,
      'count': this.count,
    };
  }

  factory ProjectWithCount.fromMap(Map<String, dynamic> map) {
    return ProjectWithCount(
      id: map['id'] as int,
      name: map['name'] as String,
      colorCode: map['colorCode'] as int,
      colorName: map['colorName'] as String,
      count: map['count'] as int,
    );
  }
}

extension ProjectExt on ProjectWithCount {
  DataGridRow mapProjectRow() => DataGridRow(cells: [
        DataGridCell<int>(columnName: 'id', value: id),
        DataGridCell<String>(columnName: 'name', value: name),
        DataGridCell<int>(columnName: 'count', value: count),
        DataGridCell<int>(columnName: 'colorCode', value: colorCode),
        DataGridCell<String>(columnName: 'colorName', value: colorName),
      ]);
}
