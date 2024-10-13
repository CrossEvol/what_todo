import 'package:flutter_app/models/setting_type.dart';

/// inside the toMap() and fromMap(),
/// if interaction with database,
/// should be care about updateAt is Text or int inside db
class Setting {
  int? id;
  final String key;
  final String value;
  final DateTime updatedAt;
  final SettingType type;

  Setting({
    this.id,
    required this.key,
    required this.value,
    required this.updatedAt,
    required this.type,
  });

  Setting.create({
    required this.key,
    required this.value,
    required this.updatedAt,
    required this.type,
  });

  Setting.update({
    required this.id,
    required this.key,
    required this.value,
    required this.updatedAt,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'key': this.key,
      'value': this.value,
      'updatedAt': this.updatedAt,
      'type': this.type.name,
    };
  }

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'])
          : map['updatedAt'],
      type:
          SettingType.values.firstWhere((e) => e.name == map['type'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Setting &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          value == other.value &&
          updatedAt == other.updatedAt &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      key.hashCode ^
      value.hashCode ^
      updatedAt.hashCode ^
      type.hashCode;
}
