import 'package:drift/drift.dart';
import 'package:flutter_app/models/setting_type.dart';

class Project extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get colorName => text()();

  IntColumn get colorCode => integer()();
}

class Task extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get comment => text().nullable()();

  // v3
  // IntColumn get dueDate => integer().nullable()();

  // v2
  // DateTimeColumn get updatedAt => dateTime().nullable()();

  // v4
  DateTimeColumn get dueDate => dateTime().nullable()();

  IntColumn get priority => integer().nullable()();

  IntColumn get projectId => integer()
      .customConstraint('NOT NULL REFERENCES project(id) ON DELETE CASCADE')();

  IntColumn get status => integer()();

  // v7
  IntColumn get order => integer().withDefault(const Constant(0))();
}

class Label extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get colorName => text()();

  IntColumn get colorCode => integer()();
}

class TaskLabel extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer()
      .customConstraint('NOT NULL REFERENCES task(id) ON DELETE CASCADE')();

  IntColumn get labelId => integer()
      .customConstraint('NOT NULL REFERENCES label(id) ON DELETE CASCADE')();
}

class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withDefault(const Constant(""))();

  TextColumn get email => text().unique()();

  TextColumn get avatarUrl => text().withDefault(
      const Constant(""))(); // Assuming the picture URL might be optional
  IntColumn get updatedAt => integer().nullable()();
}

class Setting extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get key => text().unique()();

  TextColumn get value => text().withDefault(const Constant(""))();

  DateTimeColumn get updatedAt =>
      dateTime().customConstraint("DEFAULT CURRENT_TIMESTAMP")();

  TextColumn get type => textEnum<SettingType>()
      .customConstraint('DEFAULT ${SettingType.Text.name}')();
}

class DriftSchema extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get version => integer().withDefault(const Constant(0))();
}
