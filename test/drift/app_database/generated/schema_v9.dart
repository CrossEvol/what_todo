// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Project extends Table with TableInfo<Project, ProjectData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Project(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
      'color_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> colorCode = GeneratedColumn<int>(
      'color_code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, colorName, colorCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_name'])!,
      colorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_code'])!,
    );
  }

  @override
  Project createAlias(String alias) {
    return Project(attachedDatabase, alias);
  }
}

class ProjectData extends DataClass implements Insertable<ProjectData> {
  final int id;
  final String name;
  final String colorName;
  final int colorCode;
  const ProjectData(
      {required this.id,
      required this.name,
      required this.colorName,
      required this.colorCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_name'] = Variable<String>(colorName);
    map['color_code'] = Variable<int>(colorCode);
    return map;
  }

  ProjectCompanion toCompanion(bool nullToAbsent) {
    return ProjectCompanion(
      id: Value(id),
      name: Value(name),
      colorName: Value(colorName),
      colorCode: Value(colorCode),
    );
  }

  factory ProjectData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorName: serializer.fromJson<String>(json['colorName']),
      colorCode: serializer.fromJson<int>(json['colorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorName': serializer.toJson<String>(colorName),
      'colorCode': serializer.toJson<int>(colorCode),
    };
  }

  ProjectData copyWith(
          {int? id, String? name, String? colorName, int? colorCode}) =>
      ProjectData(
        id: id ?? this.id,
        name: name ?? this.name,
        colorName: colorName ?? this.colorName,
        colorCode: colorCode ?? this.colorCode,
      );
  ProjectData copyWithCompanion(ProjectCompanion data) {
    return ProjectData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorName: data.colorName.present ? data.colorName.value : this.colorName,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorName: $colorName, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorName, colorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorName == this.colorName &&
          other.colorCode == this.colorCode);
}

class ProjectCompanion extends UpdateCompanion<ProjectData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorName;
  final Value<int> colorCode;
  const ProjectCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorName = const Value.absent(),
    this.colorCode = const Value.absent(),
  });
  ProjectCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String colorName,
    required int colorCode,
  })  : name = Value(name),
        colorName = Value(colorName),
        colorCode = Value(colorCode);
  static Insertable<ProjectData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorName,
    Expression<int>? colorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorName != null) 'color_name': colorName,
      if (colorCode != null) 'color_code': colorCode,
    });
  }

  ProjectCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? colorName,
      Value<int>? colorCode}) {
    return ProjectCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorName: colorName ?? this.colorName,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorName.present) {
      map['color_name'] = Variable<String>(colorName.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<int>(colorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorName: $colorName, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }
}

class Task extends Table with TableInfo<Task, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Task(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES project(id) ON DELETE CASCADE');
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, comment, dueDate, priority, projectId, status, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority']),
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
    );
  }

  @override
  Task createAlias(String alias) {
    return Task(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  final int id;
  final String title;
  final String? comment;
  final DateTime? dueDate;
  final int? priority;
  final int projectId;
  final int status;
  final int order;
  const TaskData(
      {required this.id,
      required this.title,
      this.comment,
      this.dueDate,
      this.priority,
      required this.projectId,
      required this.status,
      required this.order});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    map['project_id'] = Variable<int>(projectId);
    map['status'] = Variable<int>(status);
    map['order'] = Variable<int>(order);
    return map;
  }

  TaskCompanion toCompanion(bool nullToAbsent) {
    return TaskCompanion(
      id: Value(id),
      title: Value(title),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      projectId: Value(projectId),
      status: Value(status),
      order: Value(order),
    );
  }

  factory TaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      comment: serializer.fromJson<String?>(json['comment']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      priority: serializer.fromJson<int?>(json['priority']),
      projectId: serializer.fromJson<int>(json['projectId']),
      status: serializer.fromJson<int>(json['status']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'comment': serializer.toJson<String?>(comment),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'priority': serializer.toJson<int?>(priority),
      'projectId': serializer.toJson<int>(projectId),
      'status': serializer.toJson<int>(status),
      'order': serializer.toJson<int>(order),
    };
  }

  TaskData copyWith(
          {int? id,
          String? title,
          Value<String?> comment = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<int?> priority = const Value.absent(),
          int? projectId,
          int? status,
          int? order}) =>
      TaskData(
        id: id ?? this.id,
        title: title ?? this.title,
        comment: comment.present ? comment.value : this.comment,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        priority: priority.present ? priority.value : this.priority,
        projectId: projectId ?? this.projectId,
        status: status ?? this.status,
        order: order ?? this.order,
      );
  TaskData copyWithCompanion(TaskCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      comment: data.comment.present ? data.comment.value : this.comment,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      status: data.status.present ? data.status.value : this.status,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('comment: $comment, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, comment, dueDate, priority, projectId, status, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.title == this.title &&
          other.comment == this.comment &&
          other.dueDate == this.dueDate &&
          other.priority == this.priority &&
          other.projectId == this.projectId &&
          other.status == this.status &&
          other.order == this.order);
}

class TaskCompanion extends UpdateCompanion<TaskData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> comment;
  final Value<DateTime?> dueDate;
  final Value<int?> priority;
  final Value<int> projectId;
  final Value<int> status;
  final Value<int> order;
  const TaskCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.comment = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    this.order = const Value.absent(),
  });
  TaskCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.comment = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    required int projectId,
    required int status,
    this.order = const Value.absent(),
  })  : title = Value(title),
        projectId = Value(projectId),
        status = Value(status);
  static Insertable<TaskData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? comment,
    Expression<DateTime>? dueDate,
    Expression<int>? priority,
    Expression<int>? projectId,
    Expression<int>? status,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (comment != null) 'comment': comment,
      if (dueDate != null) 'due_date': dueDate,
      if (priority != null) 'priority': priority,
      if (projectId != null) 'project_id': projectId,
      if (status != null) 'status': status,
      if (order != null) 'order': order,
    });
  }

  TaskCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? comment,
      Value<DateTime?>? dueDate,
      Value<int?>? priority,
      Value<int>? projectId,
      Value<int>? status,
      Value<int>? order}) {
    return TaskCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('comment: $comment, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class Label extends Table with TableInfo<Label, LabelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Label(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
      'color_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> colorCode = GeneratedColumn<int>(
      'color_code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, colorName, colorCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'label';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_name'])!,
      colorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_code'])!,
    );
  }

  @override
  Label createAlias(String alias) {
    return Label(attachedDatabase, alias);
  }
}

class LabelData extends DataClass implements Insertable<LabelData> {
  final int id;
  final String name;
  final String colorName;
  final int colorCode;
  const LabelData(
      {required this.id,
      required this.name,
      required this.colorName,
      required this.colorCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_name'] = Variable<String>(colorName);
    map['color_code'] = Variable<int>(colorCode);
    return map;
  }

  LabelCompanion toCompanion(bool nullToAbsent) {
    return LabelCompanion(
      id: Value(id),
      name: Value(name),
      colorName: Value(colorName),
      colorCode: Value(colorCode),
    );
  }

  factory LabelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabelData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorName: serializer.fromJson<String>(json['colorName']),
      colorCode: serializer.fromJson<int>(json['colorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorName': serializer.toJson<String>(colorName),
      'colorCode': serializer.toJson<int>(colorCode),
    };
  }

  LabelData copyWith(
          {int? id, String? name, String? colorName, int? colorCode}) =>
      LabelData(
        id: id ?? this.id,
        name: name ?? this.name,
        colorName: colorName ?? this.colorName,
        colorCode: colorCode ?? this.colorCode,
      );
  LabelData copyWithCompanion(LabelCompanion data) {
    return LabelData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorName: data.colorName.present ? data.colorName.value : this.colorName,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabelData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorName: $colorName, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorName, colorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabelData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorName == this.colorName &&
          other.colorCode == this.colorCode);
}

class LabelCompanion extends UpdateCompanion<LabelData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorName;
  final Value<int> colorCode;
  const LabelCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorName = const Value.absent(),
    this.colorCode = const Value.absent(),
  });
  LabelCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String colorName,
    required int colorCode,
  })  : name = Value(name),
        colorName = Value(colorName),
        colorCode = Value(colorCode);
  static Insertable<LabelData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorName,
    Expression<int>? colorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorName != null) 'color_name': colorName,
      if (colorCode != null) 'color_code': colorCode,
    });
  }

  LabelCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? colorName,
      Value<int>? colorCode}) {
    return LabelCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorName: colorName ?? this.colorName,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorName.present) {
      map['color_name'] = Variable<String>(colorName.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<int>(colorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorName: $colorName, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }
}

class TaskLabel extends Table with TableInfo<TaskLabel, TaskLabelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TaskLabel(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES task(id) ON DELETE CASCADE');
  late final GeneratedColumn<int> labelId = GeneratedColumn<int>(
      'label_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES label(id) ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns => [id, taskId, labelId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_label';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskLabelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskLabelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      labelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}label_id'])!,
    );
  }

  @override
  TaskLabel createAlias(String alias) {
    return TaskLabel(attachedDatabase, alias);
  }
}

class TaskLabelData extends DataClass implements Insertable<TaskLabelData> {
  final int id;
  final int taskId;
  final int labelId;
  const TaskLabelData(
      {required this.id, required this.taskId, required this.labelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['label_id'] = Variable<int>(labelId);
    return map;
  }

  TaskLabelCompanion toCompanion(bool nullToAbsent) {
    return TaskLabelCompanion(
      id: Value(id),
      taskId: Value(taskId),
      labelId: Value(labelId),
    );
  }

  factory TaskLabelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskLabelData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      labelId: serializer.fromJson<int>(json['labelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'labelId': serializer.toJson<int>(labelId),
    };
  }

  TaskLabelData copyWith({int? id, int? taskId, int? labelId}) => TaskLabelData(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        labelId: labelId ?? this.labelId,
      );
  TaskLabelData copyWithCompanion(TaskLabelCompanion data) {
    return TaskLabelData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskLabelData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, labelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskLabelData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.labelId == this.labelId);
}

class TaskLabelCompanion extends UpdateCompanion<TaskLabelData> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<int> labelId;
  const TaskLabelCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.labelId = const Value.absent(),
  });
  TaskLabelCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required int labelId,
  })  : taskId = Value(taskId),
        labelId = Value(labelId);
  static Insertable<TaskLabelData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<int>? labelId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (labelId != null) 'label_id': labelId,
    });
  }

  TaskLabelCompanion copyWith(
      {Value<int>? id, Value<int>? taskId, Value<int>? labelId}) {
    return TaskLabelCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      labelId: labelId ?? this.labelId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<int>(labelId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskLabelCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }
}

class Profile extends Table with TableInfo<Profile, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profile(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, email, avatarUrl, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  Profile createAlias(String alias) {
    return Profile(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String name;
  final String email;
  final String avatarUrl;
  final int? updatedAt;
  const ProfileData(
      {required this.id,
      required this.name,
      required this.email,
      required this.avatarUrl,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['avatar_url'] = Variable<String>(avatarUrl);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      avatarUrl: Value(avatarUrl),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  ProfileData copyWith(
          {int? id,
          String? name,
          String? email,
          String? avatarUrl,
          Value<int?> updatedAt = const Value.absent()}) =>
      ProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, avatarUrl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.updatedAt == this.updatedAt);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> avatarUrl;
  final Value<int?> updatedAt;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String email,
    this.avatarUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : email = Value(email);
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfileCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? avatarUrl,
      Value<int?>? updatedAt}) {
    return ProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class Setting extends Table with TableInfo<Setting, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Setting(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: 'DEFAULT CURRENT_TIMESTAMP',
      defaultValue: const CustomExpression('CURRENT_TIMESTAMP'));
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, key, value, updatedAt, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  Setting createAlias(String alias) {
    return Setting(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final int id;
  final String key;
  final String value;
  final DateTime updatedAt;
  final String type;
  const SettingData(
      {required this.id,
      required this.key,
      required this.value,
      required this.updatedAt,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['type'] = Variable<String>(type);
    return map;
  }

  SettingCompanion toCompanion(bool nullToAbsent) {
    return SettingCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      type: Value(type),
    );
  }

  factory SettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'type': serializer.toJson<String>(type),
    };
  }

  SettingData copyWith(
          {int? id,
          String? key,
          String? value,
          DateTime? updatedAt,
          String? type}) =>
      SettingData(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
        type: type ?? this.type,
      );
  SettingData copyWithCompanion(SettingCompanion data) {
    return SettingData(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value, updatedAt, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.type == this.type);
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<String> type;
  const SettingCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.type = const Value.absent(),
  });
  SettingCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String type,
  })  : key = Value(key),
        type = Value(type);
  static Insertable<SettingData> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (type != null) 'type': type,
    });
  }

  SettingCompanion copyWith(
      {Value<int>? id,
      Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<String>? type}) {
    return SettingCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class DriftSchema extends Table with TableInfo<DriftSchema, DriftSchemaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DriftSchema(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns => [id, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drift_schema';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriftSchemaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftSchemaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  DriftSchema createAlias(String alias) {
    return DriftSchema(attachedDatabase, alias);
  }
}

class DriftSchemaData extends DataClass implements Insertable<DriftSchemaData> {
  final int id;
  final int version;
  const DriftSchemaData({required this.id, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<int>(version);
    return map;
  }

  DriftSchemaCompanion toCompanion(bool nullToAbsent) {
    return DriftSchemaCompanion(
      id: Value(id),
      version: Value(version),
    );
  }

  factory DriftSchemaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftSchemaData(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int>(version),
    };
  }

  DriftSchemaData copyWith({int? id, int? version}) => DriftSchemaData(
        id: id ?? this.id,
        version: version ?? this.version,
      );
  DriftSchemaData copyWithCompanion(DriftSchemaCompanion data) {
    return DriftSchemaData(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriftSchemaData(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftSchemaData &&
          other.id == this.id &&
          other.version == this.version);
}

class DriftSchemaCompanion extends UpdateCompanion<DriftSchemaData> {
  final Value<int> id;
  final Value<int> version;
  const DriftSchemaCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
  });
  DriftSchemaCompanion.insert({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
  });
  static Insertable<DriftSchemaData> custom({
    Expression<int>? id,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
    });
  }

  DriftSchemaCompanion copyWith({Value<int>? id, Value<int>? version}) {
    return DriftSchemaCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriftSchemaCompanion(')
          ..write('id: $id, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class Reminder extends Table with TableInfo<Reminder, ReminderData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Reminder(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> remindTime = GeneratedColumn<DateTime>(
      'remind_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<bool> enable = GeneratedColumn<bool>(
      'enable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enable" IN (0, 1))'),
      defaultValue: const CustomExpression('1'));
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES task(id) ON DELETE CASCADE');
  late final GeneratedColumn<DateTime> updateTime = GeneratedColumn<DateTime>(
      'update_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, remindTime, enable, taskId, updateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      remindTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}remind_time']),
      enable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enable'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      updateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_time']),
    );
  }

  @override
  Reminder createAlias(String alias) {
    return Reminder(attachedDatabase, alias);
  }
}

class ReminderData extends DataClass implements Insertable<ReminderData> {
  final int id;
  final String type;
  final DateTime? remindTime;
  final bool enable;
  final int? taskId;
  final DateTime? updateTime;
  const ReminderData(
      {required this.id,
      required this.type,
      this.remindTime,
      required this.enable,
      this.taskId,
      this.updateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || remindTime != null) {
      map['remind_time'] = Variable<DateTime>(remindTime);
    }
    map['enable'] = Variable<bool>(enable);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || updateTime != null) {
      map['update_time'] = Variable<DateTime>(updateTime);
    }
    return map;
  }

  ReminderCompanion toCompanion(bool nullToAbsent) {
    return ReminderCompanion(
      id: Value(id),
      type: Value(type),
      remindTime: remindTime == null && nullToAbsent
          ? const Value.absent()
          : Value(remindTime),
      enable: Value(enable),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      updateTime: updateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(updateTime),
    );
  }

  factory ReminderData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      remindTime: serializer.fromJson<DateTime?>(json['remindTime']),
      enable: serializer.fromJson<bool>(json['enable']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      updateTime: serializer.fromJson<DateTime?>(json['updateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'remindTime': serializer.toJson<DateTime?>(remindTime),
      'enable': serializer.toJson<bool>(enable),
      'taskId': serializer.toJson<int?>(taskId),
      'updateTime': serializer.toJson<DateTime?>(updateTime),
    };
  }

  ReminderData copyWith(
          {int? id,
          String? type,
          Value<DateTime?> remindTime = const Value.absent(),
          bool? enable,
          Value<int?> taskId = const Value.absent(),
          Value<DateTime?> updateTime = const Value.absent()}) =>
      ReminderData(
        id: id ?? this.id,
        type: type ?? this.type,
        remindTime: remindTime.present ? remindTime.value : this.remindTime,
        enable: enable ?? this.enable,
        taskId: taskId.present ? taskId.value : this.taskId,
        updateTime: updateTime.present ? updateTime.value : this.updateTime,
      );
  ReminderData copyWithCompanion(ReminderCompanion data) {
    return ReminderData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      remindTime:
          data.remindTime.present ? data.remindTime.value : this.remindTime,
      enable: data.enable.present ? data.enable.value : this.enable,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      updateTime:
          data.updateTime.present ? data.updateTime.value : this.updateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('remindTime: $remindTime, ')
          ..write('enable: $enable, ')
          ..write('taskId: $taskId, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, remindTime, enable, taskId, updateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderData &&
          other.id == this.id &&
          other.type == this.type &&
          other.remindTime == this.remindTime &&
          other.enable == this.enable &&
          other.taskId == this.taskId &&
          other.updateTime == this.updateTime);
}

class ReminderCompanion extends UpdateCompanion<ReminderData> {
  final Value<int> id;
  final Value<String> type;
  final Value<DateTime?> remindTime;
  final Value<bool> enable;
  final Value<int?> taskId;
  final Value<DateTime?> updateTime;
  const ReminderCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.remindTime = const Value.absent(),
    this.enable = const Value.absent(),
    this.taskId = const Value.absent(),
    this.updateTime = const Value.absent(),
  });
  ReminderCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.remindTime = const Value.absent(),
    this.enable = const Value.absent(),
    this.taskId = const Value.absent(),
    this.updateTime = const Value.absent(),
  }) : type = Value(type);
  static Insertable<ReminderData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? remindTime,
    Expression<bool>? enable,
    Expression<int>? taskId,
    Expression<DateTime>? updateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (remindTime != null) 'remind_time': remindTime,
      if (enable != null) 'enable': enable,
      if (taskId != null) 'task_id': taskId,
      if (updateTime != null) 'update_time': updateTime,
    });
  }

  ReminderCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<DateTime?>? remindTime,
      Value<bool>? enable,
      Value<int?>? taskId,
      Value<DateTime?>? updateTime}) {
    return ReminderCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      remindTime: remindTime ?? this.remindTime,
      enable: enable ?? this.enable,
      taskId: taskId ?? this.taskId,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (remindTime.present) {
      map['remind_time'] = Variable<DateTime>(remindTime.value);
    }
    if (enable.present) {
      map['enable'] = Variable<bool>(enable.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<DateTime>(updateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('remindTime: $remindTime, ')
          ..write('enable: $enable, ')
          ..write('taskId: $taskId, ')
          ..write('updateTime: $updateTime')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV9 extends GeneratedDatabase {
  DatabaseAtV9(QueryExecutor e) : super(e);
  late final Project project = Project(this);
  late final Task task = Task(this);
  late final Label label = Label(this);
  late final TaskLabel taskLabel = TaskLabel(this);
  late final Profile profile = Profile(this);
  late final Setting setting = Setting(this);
  late final DriftSchema driftSchema = DriftSchema(this);
  late final Reminder reminder = Reminder(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        project,
        task,
        label,
        taskLabel,
        profile,
        setting,
        driftSchema,
        reminder
      ];
  @override
  int get schemaVersion => 9;
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
