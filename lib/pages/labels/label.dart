import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Label {
  static final tblLabel = "label"; // Changed from "labels" to "label"
  static final dbId = "id";
  static final dbName = "name";
  static final dbColorCode = "colorCode";
  static final dbColorName = "colorName";

  int? id;
  late int colorValue;
  late String name;
  late String colorName;

  Label.create(this.name, this.colorValue, this.colorName);

  Label.update({required this.id, name = "", colorCode = "", colorName = ""}) {
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

  bool operator ==(o) => o is Label && o.id == id;

  Label.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId],
            name: map[dbName],
            colorCode: map[dbColorCode],
            colorName: map[dbColorName]);

  Map<String, dynamic> toMap() {
    return {
      Label.dbId: id,
      Label.dbName: name,
      Label.dbColorCode: colorValue,
      Label.dbColorName: colorName,
    };
  }
}

class LabelWithCount {
  final int id;
  final String name;
  final int colorCode;
  final String colorName;
  final int count;

  const LabelWithCount({
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

  factory LabelWithCount.fromMap(Map<String, dynamic> map) {
    return LabelWithCount(
      id: map['id'] as int,
      name: map['name'] as String,
      colorCode: map['colorCode'] as int,
      colorName: map['colorName'] as String,
      count: map['count'] as int,
    );
  }
}

extension LabelExt on LabelWithCount {
  DataGridRow mapEmployeeRow() => DataGridRow(cells: [
        DataGridCell<int>(columnName: 'id', value: id),
        DataGridCell<String>(columnName: 'name', value: name),
        DataGridCell<int>(columnName: 'count', value: count),
        DataGridCell<int>(columnName: 'colorCode', value: colorCode),
        DataGridCell<String>(columnName: 'colorName', value: colorName),
      ]);
}
