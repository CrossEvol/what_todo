// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $ProjectTable extends Project with TableInfo<$ProjectTable, ProjectData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorNameMeta =
      const VerificationMeta('colorName');
  @override
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
      'color_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorCodeMeta =
      const VerificationMeta('colorCode');
  @override
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
  VerificationContext validateIntegrity(Insertable<ProjectData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_name')) {
      context.handle(_colorNameMeta,
          colorName.isAcceptableOrUnknown(data['color_name']!, _colorNameMeta));
    } else if (isInserting) {
      context.missing(_colorNameMeta);
    }
    if (data.containsKey('color_code')) {
      context.handle(_colorCodeMeta,
          colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta));
    } else if (isInserting) {
      context.missing(_colorCodeMeta);
    }
    return context;
  }

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
  $ProjectTable createAlias(String alias) {
    return $ProjectTable(attachedDatabase, alias);
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

class $TaskTable extends Task with TableInfo<$TaskTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES project(id) ON DELETE CASCADE');
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, comment, dueDate, priority, projectId, status, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task';
  @override
  VerificationContext validateIntegrity(Insertable<TaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    return context;
  }

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
  $TaskTable createAlias(String alias) {
    return $TaskTable(attachedDatabase, alias);
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

class $LabelTable extends Label with TableInfo<$LabelTable, LabelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorNameMeta =
      const VerificationMeta('colorName');
  @override
  late final GeneratedColumn<String> colorName = GeneratedColumn<String>(
      'color_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorCodeMeta =
      const VerificationMeta('colorCode');
  @override
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
  VerificationContext validateIntegrity(Insertable<LabelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_name')) {
      context.handle(_colorNameMeta,
          colorName.isAcceptableOrUnknown(data['color_name']!, _colorNameMeta));
    } else if (isInserting) {
      context.missing(_colorNameMeta);
    }
    if (data.containsKey('color_code')) {
      context.handle(_colorCodeMeta,
          colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta));
    } else if (isInserting) {
      context.missing(_colorCodeMeta);
    }
    return context;
  }

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
  $LabelTable createAlias(String alias) {
    return $LabelTable(attachedDatabase, alias);
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

class $TaskLabelTable extends TaskLabel
    with TableInfo<$TaskLabelTable, TaskLabelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskLabelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES task(id) ON DELETE CASCADE');
  static const VerificationMeta _labelIdMeta =
      const VerificationMeta('labelId');
  @override
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
  VerificationContext validateIntegrity(Insertable<TaskLabelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(_labelIdMeta,
          labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta));
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    return context;
  }

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
  $TaskLabelTable createAlias(String alias) {
    return $TaskLabelTable(attachedDatabase, alias);
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

class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
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
  VerificationContext validateIntegrity(Insertable<ProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

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
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
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

class $SettingTable extends Setting with TableInfo<$SettingTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: 'DEFAULT CURRENT_TIMESTAMP',
      defaultValue: const CustomExpression('CURRENT_TIMESTAMP'));
  @override
  late final GeneratedColumnWithTypeConverter<SettingType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SettingType>($SettingTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [id, key, value, updatedAt, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  VerificationContext validateIntegrity(Insertable<SettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

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
      type: $SettingTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $SettingTable createAlias(String alias) {
    return $SettingTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SettingType, String, String> $convertertype =
      const EnumNameConverter<SettingType>(SettingType.values);
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final int id;
  final String key;
  final String value;
  final DateTime updatedAt;
  final SettingType type;
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
    {
      map['type'] = Variable<String>($SettingTable.$convertertype.toSql(type));
    }
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
      type: $SettingTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
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
      'type':
          serializer.toJson<String>($SettingTable.$convertertype.toJson(type)),
    };
  }

  SettingData copyWith(
          {int? id,
          String? key,
          String? value,
          DateTime? updatedAt,
          SettingType? type}) =>
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
  final Value<SettingType> type;
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
    required SettingType type,
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
      Value<SettingType>? type}) {
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
      map['type'] =
          Variable<String>($SettingTable.$convertertype.toSql(type.value));
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

class $DriftSchemaTable extends DriftSchema
    with TableInfo<$DriftSchemaTable, DriftSchemaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriftSchemaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drift_schema';
  @override
  VerificationContext validateIntegrity(Insertable<DriftSchemaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

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
  $DriftSchemaTable createAlias(String alias) {
    return $DriftSchemaTable(attachedDatabase, alias);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectTable project = $ProjectTable(this);
  late final $TaskTable task = $TaskTable(this);
  late final $LabelTable label = $LabelTable(this);
  late final $TaskLabelTable taskLabel = $TaskLabelTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $SettingTable setting = $SettingTable(this);
  late final $DriftSchemaTable driftSchema = $DriftSchemaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [project, task, label, taskLabel, profile, setting, driftSchema];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('project',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('task',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_label', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('label',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_label', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProjectTableCreateCompanionBuilder = ProjectCompanion Function({
  Value<int> id,
  required String name,
  required String colorName,
  required int colorCode,
});
typedef $$ProjectTableUpdateCompanionBuilder = ProjectCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> colorName,
  Value<int> colorCode,
});

final class $$ProjectTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectTable, ProjectData> {
  $$ProjectTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskTable, List<TaskData>> _taskRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.task,
          aliasName: $_aliasNameGenerator(db.project.id, db.task.projectId));

  $$TaskTableProcessedTableManager get taskRefs {
    final manager = $$TaskTableTableManager($_db, $_db.task)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTable> {
  $$ProjectTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnFilters(column));

  Expression<bool> taskRefs(
      Expression<bool> Function($$TaskTableFilterComposer f) f) {
    final $$TaskTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.task,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTableFilterComposer(
              $db: $db,
              $table: $db.task,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTable> {
  $$ProjectTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTable> {
  $$ProjectTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorName =>
      $composableBuilder(column: $table.colorName, builder: (column) => column);

  GeneratedColumn<int> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  Expression<T> taskRefs<T extends Object>(
      Expression<T> Function($$TaskTableAnnotationComposer a) f) {
    final $$TaskTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.task,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTableAnnotationComposer(
              $db: $db,
              $table: $db.task,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTable,
    ProjectData,
    $$ProjectTableFilterComposer,
    $$ProjectTableOrderingComposer,
    $$ProjectTableAnnotationComposer,
    $$ProjectTableCreateCompanionBuilder,
    $$ProjectTableUpdateCompanionBuilder,
    (ProjectData, $$ProjectTableReferences),
    ProjectData,
    PrefetchHooks Function({bool taskRefs})> {
  $$ProjectTableTableManager(_$AppDatabase db, $ProjectTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorName = const Value.absent(),
            Value<int> colorCode = const Value.absent(),
          }) =>
              ProjectCompanion(
            id: id,
            name: name,
            colorName: colorName,
            colorCode: colorCode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String colorName,
            required int colorCode,
          }) =>
              ProjectCompanion.insert(
            id: id,
            name: name,
            colorName: colorName,
            colorCode: colorCode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskRefs) db.task],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskRefs)
                    await $_getPrefetchedData<ProjectData, $ProjectTable,
                            TaskData>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectTableReferences._taskRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectTableReferences(db, table, p0).taskRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectTable,
    ProjectData,
    $$ProjectTableFilterComposer,
    $$ProjectTableOrderingComposer,
    $$ProjectTableAnnotationComposer,
    $$ProjectTableCreateCompanionBuilder,
    $$ProjectTableUpdateCompanionBuilder,
    (ProjectData, $$ProjectTableReferences),
    ProjectData,
    PrefetchHooks Function({bool taskRefs})>;
typedef $$TaskTableCreateCompanionBuilder = TaskCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> comment,
  Value<DateTime?> dueDate,
  Value<int?> priority,
  required int projectId,
  required int status,
  Value<int> order,
});
typedef $$TaskTableUpdateCompanionBuilder = TaskCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> comment,
  Value<DateTime?> dueDate,
  Value<int?> priority,
  Value<int> projectId,
  Value<int> status,
  Value<int> order,
});

final class $$TaskTableReferences
    extends BaseReferences<_$AppDatabase, $TaskTable, TaskData> {
  $$TaskTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectTable _projectIdTable(_$AppDatabase db) => db.project
      .createAlias($_aliasNameGenerator(db.task.projectId, db.project.id));

  $$ProjectTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectTableTableManager($_db, $_db.project)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskLabelTable, List<TaskLabelData>>
      _taskLabelRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskLabel,
              aliasName: $_aliasNameGenerator(db.task.id, db.taskLabel.taskId));

  $$TaskLabelTableProcessedTableManager get taskLabelRefs {
    final manager = $$TaskLabelTableTableManager($_db, $_db.taskLabel)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskLabelRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TaskTableFilterComposer extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  $$ProjectTableFilterComposer get projectId {
    final $$ProjectTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.project,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectTableFilterComposer(
              $db: $db,
              $table: $db.project,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskLabelRefs(
      Expression<bool> Function($$TaskLabelTableFilterComposer f) f) {
    final $$TaskLabelTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskLabel,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskLabelTableFilterComposer(
              $db: $db,
              $table: $db.taskLabel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TaskTableOrderingComposer extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  $$ProjectTableOrderingComposer get projectId {
    final $$ProjectTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.project,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectTableOrderingComposer(
              $db: $db,
              $table: $db.project,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTable> {
  $$TaskTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$ProjectTableAnnotationComposer get projectId {
    final $$ProjectTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.project,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectTableAnnotationComposer(
              $db: $db,
              $table: $db.project,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskLabelRefs<T extends Object>(
      Expression<T> Function($$TaskLabelTableAnnotationComposer a) f) {
    final $$TaskLabelTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskLabel,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskLabelTableAnnotationComposer(
              $db: $db,
              $table: $db.taskLabel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TaskTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskTable,
    TaskData,
    $$TaskTableFilterComposer,
    $$TaskTableOrderingComposer,
    $$TaskTableAnnotationComposer,
    $$TaskTableCreateCompanionBuilder,
    $$TaskTableUpdateCompanionBuilder,
    (TaskData, $$TaskTableReferences),
    TaskData,
    PrefetchHooks Function({bool projectId, bool taskLabelRefs})> {
  $$TaskTableTableManager(_$AppDatabase db, $TaskTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<int> order = const Value.absent(),
          }) =>
              TaskCompanion(
            id: id,
            title: title,
            comment: comment,
            dueDate: dueDate,
            priority: priority,
            projectId: projectId,
            status: status,
            order: order,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> comment = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            required int projectId,
            required int status,
            Value<int> order = const Value.absent(),
          }) =>
              TaskCompanion.insert(
            id: id,
            title: title,
            comment: comment,
            dueDate: dueDate,
            priority: priority,
            projectId: projectId,
            status: status,
            order: order,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TaskTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({projectId = false, taskLabelRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskLabelRefs) db.taskLabel],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable: $$TaskTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$TaskTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskLabelRefs)
                    await $_getPrefetchedData<TaskData, $TaskTable,
                            TaskLabelData>(
                        currentTable: table,
                        referencedTable:
                            $$TaskTableReferences._taskLabelRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TaskTableReferences(db, table, p0).taskLabelRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TaskTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskTable,
    TaskData,
    $$TaskTableFilterComposer,
    $$TaskTableOrderingComposer,
    $$TaskTableAnnotationComposer,
    $$TaskTableCreateCompanionBuilder,
    $$TaskTableUpdateCompanionBuilder,
    (TaskData, $$TaskTableReferences),
    TaskData,
    PrefetchHooks Function({bool projectId, bool taskLabelRefs})>;
typedef $$LabelTableCreateCompanionBuilder = LabelCompanion Function({
  Value<int> id,
  required String name,
  required String colorName,
  required int colorCode,
});
typedef $$LabelTableUpdateCompanionBuilder = LabelCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> colorName,
  Value<int> colorCode,
});

final class $$LabelTableReferences
    extends BaseReferences<_$AppDatabase, $LabelTable, LabelData> {
  $$LabelTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskLabelTable, List<TaskLabelData>>
      _taskLabelRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.taskLabel,
          aliasName: $_aliasNameGenerator(db.label.id, db.taskLabel.labelId));

  $$TaskLabelTableProcessedTableManager get taskLabelRefs {
    final manager = $$TaskLabelTableTableManager($_db, $_db.taskLabel)
        .filter((f) => f.labelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskLabelRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LabelTableFilterComposer extends Composer<_$AppDatabase, $LabelTable> {
  $$LabelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnFilters(column));

  Expression<bool> taskLabelRefs(
      Expression<bool> Function($$TaskLabelTableFilterComposer f) f) {
    final $$TaskLabelTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskLabel,
        getReferencedColumn: (t) => t.labelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskLabelTableFilterComposer(
              $db: $db,
              $table: $db.taskLabel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LabelTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelTable> {
  $$LabelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorName => $composableBuilder(
      column: $table.colorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnOrderings(column));
}

class $$LabelTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelTable> {
  $$LabelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorName =>
      $composableBuilder(column: $table.colorName, builder: (column) => column);

  GeneratedColumn<int> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  Expression<T> taskLabelRefs<T extends Object>(
      Expression<T> Function($$TaskLabelTableAnnotationComposer a) f) {
    final $$TaskLabelTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskLabel,
        getReferencedColumn: (t) => t.labelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskLabelTableAnnotationComposer(
              $db: $db,
              $table: $db.taskLabel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LabelTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LabelTable,
    LabelData,
    $$LabelTableFilterComposer,
    $$LabelTableOrderingComposer,
    $$LabelTableAnnotationComposer,
    $$LabelTableCreateCompanionBuilder,
    $$LabelTableUpdateCompanionBuilder,
    (LabelData, $$LabelTableReferences),
    LabelData,
    PrefetchHooks Function({bool taskLabelRefs})> {
  $$LabelTableTableManager(_$AppDatabase db, $LabelTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorName = const Value.absent(),
            Value<int> colorCode = const Value.absent(),
          }) =>
              LabelCompanion(
            id: id,
            name: name,
            colorName: colorName,
            colorCode: colorCode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String colorName,
            required int colorCode,
          }) =>
              LabelCompanion.insert(
            id: id,
            name: name,
            colorName: colorName,
            colorCode: colorCode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LabelTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskLabelRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskLabelRefs) db.taskLabel],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskLabelRefs)
                    await $_getPrefetchedData<LabelData, $LabelTable,
                            TaskLabelData>(
                        currentTable: table,
                        referencedTable:
                            $$LabelTableReferences._taskLabelRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LabelTableReferences(db, table, p0).taskLabelRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.labelId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LabelTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LabelTable,
    LabelData,
    $$LabelTableFilterComposer,
    $$LabelTableOrderingComposer,
    $$LabelTableAnnotationComposer,
    $$LabelTableCreateCompanionBuilder,
    $$LabelTableUpdateCompanionBuilder,
    (LabelData, $$LabelTableReferences),
    LabelData,
    PrefetchHooks Function({bool taskLabelRefs})>;
typedef $$TaskLabelTableCreateCompanionBuilder = TaskLabelCompanion Function({
  Value<int> id,
  required int taskId,
  required int labelId,
});
typedef $$TaskLabelTableUpdateCompanionBuilder = TaskLabelCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<int> labelId,
});

final class $$TaskLabelTableReferences
    extends BaseReferences<_$AppDatabase, $TaskLabelTable, TaskLabelData> {
  $$TaskLabelTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskTable _taskIdTable(_$AppDatabase db) => db.task
      .createAlias($_aliasNameGenerator(db.taskLabel.taskId, db.task.id));

  $$TaskTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TaskTableTableManager($_db, $_db.task)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LabelTable _labelIdTable(_$AppDatabase db) => db.label
      .createAlias($_aliasNameGenerator(db.taskLabel.labelId, db.label.id));

  $$LabelTableProcessedTableManager get labelId {
    final $_column = $_itemColumn<int>('label_id')!;

    final manager = $$LabelTableTableManager($_db, $_db.label)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_labelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskLabelTableFilterComposer
    extends Composer<_$AppDatabase, $TaskLabelTable> {
  $$TaskLabelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  $$TaskTableFilterComposer get taskId {
    final $$TaskTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.task,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTableFilterComposer(
              $db: $db,
              $table: $db.task,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LabelTableFilterComposer get labelId {
    final $$LabelTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $db.label,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LabelTableFilterComposer(
              $db: $db,
              $table: $db.label,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskLabelTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskLabelTable> {
  $$TaskLabelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  $$TaskTableOrderingComposer get taskId {
    final $$TaskTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.task,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTableOrderingComposer(
              $db: $db,
              $table: $db.task,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LabelTableOrderingComposer get labelId {
    final $$LabelTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $db.label,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LabelTableOrderingComposer(
              $db: $db,
              $table: $db.label,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskLabelTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskLabelTable> {
  $$TaskLabelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TaskTableAnnotationComposer get taskId {
    final $$TaskTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.task,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTableAnnotationComposer(
              $db: $db,
              $table: $db.task,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LabelTableAnnotationComposer get labelId {
    final $$LabelTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.labelId,
        referencedTable: $db.label,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LabelTableAnnotationComposer(
              $db: $db,
              $table: $db.label,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskLabelTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskLabelTable,
    TaskLabelData,
    $$TaskLabelTableFilterComposer,
    $$TaskLabelTableOrderingComposer,
    $$TaskLabelTableAnnotationComposer,
    $$TaskLabelTableCreateCompanionBuilder,
    $$TaskLabelTableUpdateCompanionBuilder,
    (TaskLabelData, $$TaskLabelTableReferences),
    TaskLabelData,
    PrefetchHooks Function({bool taskId, bool labelId})> {
  $$TaskLabelTableTableManager(_$AppDatabase db, $TaskLabelTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskLabelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskLabelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskLabelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<int> labelId = const Value.absent(),
          }) =>
              TaskLabelCompanion(
            id: id,
            taskId: taskId,
            labelId: labelId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required int labelId,
          }) =>
              TaskLabelCompanion.insert(
            id: id,
            taskId: taskId,
            labelId: labelId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskLabelTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false, labelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskLabelTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskLabelTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (labelId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.labelId,
                    referencedTable:
                        $$TaskLabelTableReferences._labelIdTable(db),
                    referencedColumn:
                        $$TaskLabelTableReferences._labelIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TaskLabelTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskLabelTable,
    TaskLabelData,
    $$TaskLabelTableFilterComposer,
    $$TaskLabelTableOrderingComposer,
    $$TaskLabelTableAnnotationComposer,
    $$TaskLabelTableCreateCompanionBuilder,
    $$TaskLabelTableUpdateCompanionBuilder,
    (TaskLabelData, $$TaskLabelTableReferences),
    TaskLabelData,
    PrefetchHooks Function({bool taskId, bool labelId})>;
typedef $$ProfileTableCreateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  Value<String> name,
  required String email,
  Value<String> avatarUrl,
  Value<int?> updatedAt,
});
typedef $$ProfileTableUpdateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> email,
  Value<String> avatarUrl,
  Value<int?> updatedAt,
});

class $$ProfileTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableAnnotationComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, BaseReferences<_$AppDatabase, $ProfileTable, ProfileData>),
    ProfileData,
    PrefetchHooks Function()> {
  $$ProfileTableTableManager(_$AppDatabase db, $ProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> avatarUrl = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
          }) =>
              ProfileCompanion(
            id: id,
            name: name,
            email: email,
            avatarUrl: avatarUrl,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            required String email,
            Value<String> avatarUrl = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
          }) =>
              ProfileCompanion.insert(
            id: id,
            name: name,
            email: email,
            avatarUrl: avatarUrl,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableAnnotationComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, BaseReferences<_$AppDatabase, $ProfileTable, ProfileData>),
    ProfileData,
    PrefetchHooks Function()>;
typedef $$SettingTableCreateCompanionBuilder = SettingCompanion Function({
  Value<int> id,
  required String key,
  Value<String> value,
  Value<DateTime> updatedAt,
  required SettingType type,
});
typedef $$SettingTableUpdateCompanionBuilder = SettingCompanion Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<SettingType> type,
});

class $$SettingTableFilterComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SettingType, SettingType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$SettingTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$SettingTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingTable> {
  $$SettingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SettingType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$SettingTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingTable,
    SettingData,
    $$SettingTableFilterComposer,
    $$SettingTableOrderingComposer,
    $$SettingTableAnnotationComposer,
    $$SettingTableCreateCompanionBuilder,
    $$SettingTableUpdateCompanionBuilder,
    (SettingData, BaseReferences<_$AppDatabase, $SettingTable, SettingData>),
    SettingData,
    PrefetchHooks Function()> {
  $$SettingTableTableManager(_$AppDatabase db, $SettingTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<SettingType> type = const Value.absent(),
          }) =>
              SettingCompanion(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
            type: type,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required SettingType type,
          }) =>
              SettingCompanion.insert(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingTable,
    SettingData,
    $$SettingTableFilterComposer,
    $$SettingTableOrderingComposer,
    $$SettingTableAnnotationComposer,
    $$SettingTableCreateCompanionBuilder,
    $$SettingTableUpdateCompanionBuilder,
    (SettingData, BaseReferences<_$AppDatabase, $SettingTable, SettingData>),
    SettingData,
    PrefetchHooks Function()>;
typedef $$DriftSchemaTableCreateCompanionBuilder = DriftSchemaCompanion
    Function({
  Value<int> id,
  Value<int> version,
});
typedef $$DriftSchemaTableUpdateCompanionBuilder = DriftSchemaCompanion
    Function({
  Value<int> id,
  Value<int> version,
});

class $$DriftSchemaTableFilterComposer
    extends Composer<_$AppDatabase, $DriftSchemaTable> {
  $$DriftSchemaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$DriftSchemaTableOrderingComposer
    extends Composer<_$AppDatabase, $DriftSchemaTable> {
  $$DriftSchemaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$DriftSchemaTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriftSchemaTable> {
  $$DriftSchemaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$DriftSchemaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DriftSchemaTable,
    DriftSchemaData,
    $$DriftSchemaTableFilterComposer,
    $$DriftSchemaTableOrderingComposer,
    $$DriftSchemaTableAnnotationComposer,
    $$DriftSchemaTableCreateCompanionBuilder,
    $$DriftSchemaTableUpdateCompanionBuilder,
    (
      DriftSchemaData,
      BaseReferences<_$AppDatabase, $DriftSchemaTable, DriftSchemaData>
    ),
    DriftSchemaData,
    PrefetchHooks Function()> {
  $$DriftSchemaTableTableManager(_$AppDatabase db, $DriftSchemaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriftSchemaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriftSchemaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriftSchemaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> version = const Value.absent(),
          }) =>
              DriftSchemaCompanion(
            id: id,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> version = const Value.absent(),
          }) =>
              DriftSchemaCompanion.insert(
            id: id,
            version: version,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DriftSchemaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DriftSchemaTable,
    DriftSchemaData,
    $$DriftSchemaTableFilterComposer,
    $$DriftSchemaTableOrderingComposer,
    $$DriftSchemaTableAnnotationComposer,
    $$DriftSchemaTableCreateCompanionBuilder,
    $$DriftSchemaTableUpdateCompanionBuilder,
    (
      DriftSchemaData,
      BaseReferences<_$AppDatabase, $DriftSchemaTable, DriftSchemaData>
    ),
    DriftSchemaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectTableTableManager get project =>
      $$ProjectTableTableManager(_db, _db.project);
  $$TaskTableTableManager get task => $$TaskTableTableManager(_db, _db.task);
  $$LabelTableTableManager get label =>
      $$LabelTableTableManager(_db, _db.label);
  $$TaskLabelTableTableManager get taskLabel =>
      $$TaskLabelTableTableManager(_db, _db.taskLabel);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db, _db.profile);
  $$SettingTableTableManager get setting =>
      $$SettingTableTableManager(_db, _db.setting);
  $$DriftSchemaTableTableManager get driftSchema =>
      $$DriftSchemaTableTableManager(_db, _db.driftSchema);
}
