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

  IntColumn get projectId =>
      integer().customConstraint('NOT NULL REFERENCES project(id) ON DELETE CASCADE')();

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

  IntColumn get taskId =>
      integer().customConstraint('NOT NULL REFERENCES task(id) ON DELETE CASCADE')();

  IntColumn get labelId =>
      integer().customConstraint('NOT NULL REFERENCES label(id) ON DELETE CASCADE')();
}

class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withDefault(const Constant(""))();

  TextColumn get email => text().unique()();

  TextColumn get avatarUrl => text().withDefault(
      const Constant(""))(); // Assuming the picture URL might be optional
  IntColumn get updatedAt => integer().nullable()();
}
