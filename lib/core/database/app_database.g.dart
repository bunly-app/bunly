// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedGrammarTable extends CachedGrammar
    with TableInfo<$CachedGrammarTable, CachedGrammarData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedGrammarTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<String> grammarId = GeneratedColumn<String>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [namespace, grammarId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_grammar';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedGrammarData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    } else if (isInserting) {
      context.missing(_namespaceMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, grammarId};
  @override
  CachedGrammarData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedGrammarData(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $CachedGrammarTable createAlias(String alias) {
    return $CachedGrammarTable(attachedDatabase, alias);
  }
}

class CachedGrammarData extends DataClass
    implements Insertable<CachedGrammarData> {
  final String namespace;
  final String grammarId;
  final String payload;
  const CachedGrammarData({
    required this.namespace,
    required this.grammarId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['grammar_id'] = Variable<String>(grammarId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  CachedGrammarCompanion toCompanion(bool nullToAbsent) {
    return CachedGrammarCompanion(
      namespace: Value(namespace),
      grammarId: Value(grammarId),
      payload: Value(payload),
    );
  }

  factory CachedGrammarData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedGrammarData(
      namespace: serializer.fromJson<String>(json['namespace']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'grammarId': serializer.toJson<String>(grammarId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  CachedGrammarData copyWith({
    String? namespace,
    String? grammarId,
    String? payload,
  }) => CachedGrammarData(
    namespace: namespace ?? this.namespace,
    grammarId: grammarId ?? this.grammarId,
    payload: payload ?? this.payload,
  );
  CachedGrammarData copyWithCompanion(CachedGrammarCompanion data) {
    return CachedGrammarData(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedGrammarData(')
          ..write('namespace: $namespace, ')
          ..write('grammarId: $grammarId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(namespace, grammarId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedGrammarData &&
          other.namespace == this.namespace &&
          other.grammarId == this.grammarId &&
          other.payload == this.payload);
}

class CachedGrammarCompanion extends UpdateCompanion<CachedGrammarData> {
  final Value<String> namespace;
  final Value<String> grammarId;
  final Value<String> payload;
  final Value<int> rowid;
  const CachedGrammarCompanion({
    this.namespace = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedGrammarCompanion.insert({
    required String namespace,
    required String grammarId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       grammarId = Value(grammarId),
       payload = Value(payload);
  static Insertable<CachedGrammarData> custom({
    Expression<String>? namespace,
    Expression<String>? grammarId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (grammarId != null) 'grammar_id': grammarId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedGrammarCompanion copyWith({
    Value<String>? namespace,
    Value<String>? grammarId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return CachedGrammarCompanion(
      namespace: namespace ?? this.namespace,
      grammarId: grammarId ?? this.grammarId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedGrammarCompanion(')
          ..write('namespace: $namespace, ')
          ..write('grammarId: $grammarId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalNotesTable extends LocalNotes
    with TableInfo<$LocalNotesTable, LocalNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<String> grammarId = GeneratedColumn<String>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    ownerId,
    noteId,
    grammarId,
    content,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    } else if (isInserting) {
      context.missing(_namespaceMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, ownerId, noteId};
  @override
  LocalNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNote(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalNotesTable createAlias(String alias) {
    return $LocalNotesTable(attachedDatabase, alias);
  }
}

class LocalNote extends DataClass implements Insertable<LocalNote> {
  final String namespace;
  final String ownerId;
  final String noteId;
  final String grammarId;
  final String content;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LocalNote({
    required this.namespace,
    required this.ownerId,
    required this.noteId,
    required this.grammarId,
    required this.content,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['note_id'] = Variable<String>(noteId);
    map['grammar_id'] = Variable<String>(grammarId);
    map['content'] = Variable<String>(content);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LocalNotesCompanion toCompanion(bool nullToAbsent) {
    return LocalNotesCompanion(
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      noteId: Value(noteId),
      grammarId: Value(grammarId),
      content: Value(content),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LocalNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNote(
      namespace: serializer.fromJson<String>(json['namespace']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      noteId: serializer.fromJson<String>(json['noteId']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      content: serializer.fromJson<String>(json['content']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'ownerId': serializer.toJson<String>(ownerId),
      'noteId': serializer.toJson<String>(noteId),
      'grammarId': serializer.toJson<String>(grammarId),
      'content': serializer.toJson<String>(content),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LocalNote copyWith({
    String? namespace,
    String? ownerId,
    String? noteId,
    String? grammarId,
    String? content,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LocalNote(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    noteId: noteId ?? this.noteId,
    grammarId: grammarId ?? this.grammarId,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalNote copyWithCompanion(LocalNotesCompanion data) {
    return LocalNote(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      content: data.content.present ? data.content.value : this.content,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNote(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('noteId: $noteId, ')
          ..write('grammarId: $grammarId, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    ownerId,
    noteId,
    grammarId,
    content,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNote &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.noteId == this.noteId &&
          other.grammarId == this.grammarId &&
          other.content == this.content &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalNotesCompanion extends UpdateCompanion<LocalNote> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> noteId;
  final Value<String> grammarId;
  final Value<String> content;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LocalNotesCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.content = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNotesCompanion.insert({
    required String namespace,
    required String ownerId,
    required String noteId,
    required String grammarId,
    required String content,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       ownerId = Value(ownerId),
       noteId = Value(noteId),
       grammarId = Value(grammarId),
       content = Value(content),
       updatedAt = Value(updatedAt);
  static Insertable<LocalNote> custom({
    Expression<String>? namespace,
    Expression<String>? ownerId,
    Expression<String>? noteId,
    Expression<String>? grammarId,
    Expression<String>? content,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (noteId != null) 'note_id': noteId,
      if (grammarId != null) 'grammar_id': grammarId,
      if (content != null) 'content': content,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNotesCompanion copyWith({
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? noteId,
    Value<String>? grammarId,
    Value<String>? content,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalNotesCompanion(
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      noteId: noteId ?? this.noteId,
      grammarId: grammarId ?? this.grammarId,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotesCompanion(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('noteId: $noteId, ')
          ..write('grammarId: $grammarId, ')
          ..write('content: $content, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notes'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    namespace,
    ownerId,
    recordId,
    payload,
    entityTable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    } else if (isInserting) {
      context.missing(_namespaceMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int sequence;
  final String namespace;
  final String ownerId;
  final String recordId;
  final String payload;
  final String entityTable;
  const SyncOutboxData({
    required this.sequence,
    required this.namespace,
    required this.ownerId,
    required this.recordId,
    required this.payload,
    required this.entityTable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['entity_table'] = Variable<String>(entityTable);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      sequence: Value(sequence),
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      recordId: Value(recordId),
      payload: Value(payload),
      entityTable: Value(entityTable),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      sequence: serializer.fromJson<int>(json['sequence']),
      namespace: serializer.fromJson<String>(json['namespace']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'namespace': serializer.toJson<String>(namespace),
      'ownerId': serializer.toJson<String>(ownerId),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
      'entityTable': serializer.toJson<String>(entityTable),
    };
  }

  SyncOutboxData copyWith({
    int? sequence,
    String? namespace,
    String? ownerId,
    String? recordId,
    String? payload,
    String? entityTable,
  }) => SyncOutboxData(
    sequence: sequence ?? this.sequence,
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    entityTable: entityTable ?? this.entityTable,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('sequence: $sequence, ')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('entityTable: $entityTable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sequence, namespace, ownerId, recordId, payload, entityTable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.sequence == this.sequence &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.entityTable == this.entityTable);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> sequence;
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<String> entityTable;
  const SyncOutboxCompanion({
    this.sequence = const Value.absent(),
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.entityTable = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.sequence = const Value.absent(),
    required String namespace,
    required String ownerId,
    required String recordId,
    required String payload,
    this.entityTable = const Value.absent(),
  }) : namespace = Value(namespace),
       ownerId = Value(ownerId),
       recordId = Value(recordId),
       payload = Value(payload);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? sequence,
    Expression<String>? namespace,
    Expression<String>? ownerId,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<String>? entityTable,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (entityTable != null) 'entity_table': entityTable,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? sequence,
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? recordId,
    Value<String>? payload,
    Value<String>? entityTable,
  }) {
    return SyncOutboxCompanion(
      sequence: sequence ?? this.sequence,
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      entityTable: entityTable ?? this.entityTable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('sequence: $sequence, ')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('entityTable: $entityTable')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    ownerId,
    entityTable,
    recordId,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    } else if (isInserting) {
      context.missing(_namespaceMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    namespace,
    ownerId,
    entityTable,
    recordId,
  };
  @override
  PersonalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecord(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecord extends DataClass implements Insertable<PersonalRecord> {
  final String namespace;
  final String ownerId;
  final String entityTable;
  final String recordId;
  final String payload;
  const PersonalRecord({
    required this.namespace,
    required this.ownerId,
    required this.entityTable,
    required this.recordId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['entity_table'] = Variable<String>(entityTable);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      entityTable: Value(entityTable),
      recordId: Value(recordId),
      payload: Value(payload),
    );
  }

  factory PersonalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecord(
      namespace: serializer.fromJson<String>(json['namespace']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'ownerId': serializer.toJson<String>(ownerId),
      'entityTable': serializer.toJson<String>(entityTable),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  PersonalRecord copyWith({
    String? namespace,
    String? ownerId,
    String? entityTable,
    String? recordId,
    String? payload,
  }) => PersonalRecord(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    entityTable: entityTable ?? this.entityTable,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
  );
  PersonalRecord copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecord(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(namespace, ownerId, entityTable, recordId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.payload == this.payload);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> entityTable;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    required String namespace,
    required String ownerId,
    required String entityTable,
    required String recordId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       ownerId = Value(ownerId),
       entityTable = Value(entityTable),
       recordId = Value(recordId),
       payload = Value(payload);
  static Insertable<PersonalRecord> custom({
    Expression<String>? namespace,
    Expression<String>? ownerId,
    Expression<String>? entityTable,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (entityTable != null) 'entity_table': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? entityTable,
    Value<String>? recordId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedGrammarTable cachedGrammar = $CachedGrammarTable(this);
  late final $LocalNotesTable localNotes = $LocalNotesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedGrammar,
    localNotes,
    syncOutbox,
    personalRecords,
  ];
}

typedef $$CachedGrammarTableCreateCompanionBuilder =
    CachedGrammarCompanion Function({
      required String namespace,
      required String grammarId,
      required String payload,
      Value<int> rowid,
    });
typedef $$CachedGrammarTableUpdateCompanionBuilder =
    CachedGrammarCompanion Function({
      Value<String> namespace,
      Value<String> grammarId,
      Value<String> payload,
      Value<int> rowid,
    });

class $$CachedGrammarTableFilterComposer
    extends Composer<_$AppDatabase, $CachedGrammarTable> {
  $$CachedGrammarTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedGrammarTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedGrammarTable> {
  $$CachedGrammarTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedGrammarTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedGrammarTable> {
  $$CachedGrammarTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$CachedGrammarTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedGrammarTable,
          CachedGrammarData,
          $$CachedGrammarTableFilterComposer,
          $$CachedGrammarTableOrderingComposer,
          $$CachedGrammarTableAnnotationComposer,
          $$CachedGrammarTableCreateCompanionBuilder,
          $$CachedGrammarTableUpdateCompanionBuilder,
          (
            CachedGrammarData,
            BaseReferences<
              _$AppDatabase,
              $CachedGrammarTable,
              CachedGrammarData
            >,
          ),
          CachedGrammarData,
          PrefetchHooks Function()
        > {
  $$CachedGrammarTableTableManager(_$AppDatabase db, $CachedGrammarTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedGrammarTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedGrammarTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedGrammarTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedGrammarCompanion(
                namespace: namespace,
                grammarId: grammarId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String grammarId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => CachedGrammarCompanion.insert(
                namespace: namespace,
                grammarId: grammarId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedGrammarTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedGrammarTable,
      CachedGrammarData,
      $$CachedGrammarTableFilterComposer,
      $$CachedGrammarTableOrderingComposer,
      $$CachedGrammarTableAnnotationComposer,
      $$CachedGrammarTableCreateCompanionBuilder,
      $$CachedGrammarTableUpdateCompanionBuilder,
      (
        CachedGrammarData,
        BaseReferences<_$AppDatabase, $CachedGrammarTable, CachedGrammarData>,
      ),
      CachedGrammarData,
      PrefetchHooks Function()
    >;
typedef $$LocalNotesTableCreateCompanionBuilder =
    LocalNotesCompanion Function({
      required String namespace,
      required String ownerId,
      required String noteId,
      required String grammarId,
      required String content,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LocalNotesTableUpdateCompanionBuilder =
    LocalNotesCompanion Function({
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> noteId,
      Value<String> grammarId,
      Value<String> content,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$LocalNotesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNotesTable> {
  $$LocalNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNotesTable> {
  $$LocalNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNotesTable> {
  $$LocalNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalNotesTable,
          LocalNote,
          $$LocalNotesTableFilterComposer,
          $$LocalNotesTableOrderingComposer,
          $$LocalNotesTableAnnotationComposer,
          $$LocalNotesTableCreateCompanionBuilder,
          $$LocalNotesTableUpdateCompanionBuilder,
          (
            LocalNote,
            BaseReferences<_$AppDatabase, $LocalNotesTable, LocalNote>,
          ),
          LocalNote,
          PrefetchHooks Function()
        > {
  $$LocalNotesTableTableManager(_$AppDatabase db, $LocalNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNotesCompanion(
                namespace: namespace,
                ownerId: ownerId,
                noteId: noteId,
                grammarId: grammarId,
                content: content,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String ownerId,
                required String noteId,
                required String grammarId,
                required String content,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNotesCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                noteId: noteId,
                grammarId: grammarId,
                content: content,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalNotesTable,
      LocalNote,
      $$LocalNotesTableFilterComposer,
      $$LocalNotesTableOrderingComposer,
      $$LocalNotesTableAnnotationComposer,
      $$LocalNotesTableCreateCompanionBuilder,
      $$LocalNotesTableUpdateCompanionBuilder,
      (LocalNote, BaseReferences<_$AppDatabase, $LocalNotesTable, LocalNote>),
      LocalNote,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> sequence,
      required String namespace,
      required String ownerId,
      required String recordId,
      required String payload,
      Value<String> entityTable,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> sequence,
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> recordId,
      Value<String> payload,
      Value<String> entityTable,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> namespace = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
              }) => SyncOutboxCompanion(
                sequence: sequence,
                namespace: namespace,
                ownerId: ownerId,
                recordId: recordId,
                payload: payload,
                entityTable: entityTable,
              ),
          createCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                required String namespace,
                required String ownerId,
                required String recordId,
                required String payload,
                Value<String> entityTable = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                sequence: sequence,
                namespace: namespace,
                ownerId: ownerId,
                recordId: recordId,
                payload: payload,
                entityTable: entityTable,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      required String namespace,
      required String ownerId,
      required String entityTable,
      required String recordId,
      required String payload,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> entityTable,
      Value<String> recordId,
      Value<String> payload,
      Value<int> rowid,
    });

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecord,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (
            PersonalRecord,
            BaseReferences<
              _$AppDatabase,
              $PersonalRecordsTable,
              PersonalRecord
            >,
          ),
          PersonalRecord,
          PrefetchHooks Function()
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                namespace: namespace,
                ownerId: ownerId,
                entityTable: entityTable,
                recordId: recordId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String ownerId,
                required String entityTable,
                required String recordId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                entityTable: entityTable,
                recordId: recordId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecord,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (
        PersonalRecord,
        BaseReferences<_$AppDatabase, $PersonalRecordsTable, PersonalRecord>,
      ),
      PersonalRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedGrammarTableTableManager get cachedGrammar =>
      $$CachedGrammarTableTableManager(_db, _db.cachedGrammar);
  $$LocalNotesTableTableManager get localNotes =>
      $$LocalNotesTableTableManager(_db, _db.localNotes);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
}
