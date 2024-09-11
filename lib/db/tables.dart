import 'package:drift/drift.dart';

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
  IntColumn get dueDate => integer().nullable()();
  IntColumn get priority => integer().nullable()();
  IntColumn get projectId => integer().customConstraint('REFERENCES project(id) ON DELETE CASCADE')();
  IntColumn get status => integer()();
}

class Label extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get colorName => text()();
  IntColumn get colorCode => integer()();
}

class TaskLabel extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().customConstraint('REFERENCES task(id) ON DELETE CASCADE')();
  IntColumn get labelId => integer().customConstraint('REFERENCES label(id) ON DELETE CASCADE')();
}
