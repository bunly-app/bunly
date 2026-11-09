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

class $CachedQuestionsTable extends CachedQuestions
    with TableInfo<$CachedQuestionsTable, CachedQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedQuestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
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
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
    'question_type',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    questionId,
    grammarId,
    contentVersion,
    questionType,
    payload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedQuestion> instance, {
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
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, questionId};
  @override
  CachedQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedQuestion(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CachedQuestionsTable createAlias(String alias) {
    return $CachedQuestionsTable(attachedDatabase, alias);
  }
}

class CachedQuestion extends DataClass implements Insertable<CachedQuestion> {
  final String namespace;
  final String questionId;
  final String grammarId;
  final int contentVersion;
  final String questionType;
  final String payload;
  final DateTime? updatedAt;
  const CachedQuestion({
    required this.namespace,
    required this.questionId,
    required this.grammarId,
    required this.contentVersion,
    required this.questionType,
    required this.payload,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['question_id'] = Variable<String>(questionId);
    map['grammar_id'] = Variable<String>(grammarId);
    map['content_version'] = Variable<int>(contentVersion);
    map['question_type'] = Variable<String>(questionType);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CachedQuestionsCompanion toCompanion(bool nullToAbsent) {
    return CachedQuestionsCompanion(
      namespace: Value(namespace),
      questionId: Value(questionId),
      grammarId: Value(grammarId),
      contentVersion: Value(contentVersion),
      questionType: Value(questionType),
      payload: Value(payload),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CachedQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedQuestion(
      namespace: serializer.fromJson<String>(json['namespace']),
      questionId: serializer.fromJson<String>(json['questionId']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      questionType: serializer.fromJson<String>(json['questionType']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'questionId': serializer.toJson<String>(questionId),
      'grammarId': serializer.toJson<String>(grammarId),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'questionType': serializer.toJson<String>(questionType),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CachedQuestion copyWith({
    String? namespace,
    String? questionId,
    String? grammarId,
    int? contentVersion,
    String? questionType,
    String? payload,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CachedQuestion(
    namespace: namespace ?? this.namespace,
    questionId: questionId ?? this.questionId,
    grammarId: grammarId ?? this.grammarId,
    contentVersion: contentVersion ?? this.contentVersion,
    questionType: questionType ?? this.questionType,
    payload: payload ?? this.payload,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CachedQuestion copyWithCompanion(CachedQuestionsCompanion data) {
    return CachedQuestion(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedQuestion(')
          ..write('namespace: $namespace, ')
          ..write('questionId: $questionId, ')
          ..write('grammarId: $grammarId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('questionType: $questionType, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    questionId,
    grammarId,
    contentVersion,
    questionType,
    payload,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedQuestion &&
          other.namespace == this.namespace &&
          other.questionId == this.questionId &&
          other.grammarId == this.grammarId &&
          other.contentVersion == this.contentVersion &&
          other.questionType == this.questionType &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class CachedQuestionsCompanion extends UpdateCompanion<CachedQuestion> {
  final Value<String> namespace;
  final Value<String> questionId;
  final Value<String> grammarId;
  final Value<int> contentVersion;
  final Value<String> questionType;
  final Value<String> payload;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CachedQuestionsCompanion({
    this.namespace = const Value.absent(),
    this.questionId = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.questionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedQuestionsCompanion.insert({
    required String namespace,
    required String questionId,
    required String grammarId,
    required int contentVersion,
    required String questionType,
    required String payload,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       questionId = Value(questionId),
       grammarId = Value(grammarId),
       contentVersion = Value(contentVersion),
       questionType = Value(questionType),
       payload = Value(payload);
  static Insertable<CachedQuestion> custom({
    Expression<String>? namespace,
    Expression<String>? questionId,
    Expression<String>? grammarId,
    Expression<int>? contentVersion,
    Expression<String>? questionType,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (questionId != null) 'question_id': questionId,
      if (grammarId != null) 'grammar_id': grammarId,
      if (contentVersion != null) 'content_version': contentVersion,
      if (questionType != null) 'question_type': questionType,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedQuestionsCompanion copyWith({
    Value<String>? namespace,
    Value<String>? questionId,
    Value<String>? grammarId,
    Value<int>? contentVersion,
    Value<String>? questionType,
    Value<String>? payload,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedQuestionsCompanion(
      namespace: namespace ?? this.namespace,
      questionId: questionId ?? this.questionId,
      grammarId: grammarId ?? this.grammarId,
      contentVersion: contentVersion ?? this.contentVersion,
      questionType: questionType ?? this.questionType,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedQuestionsCompanion(')
          ..write('namespace: $namespace, ')
          ..write('questionId: $questionId, ')
          ..write('grammarId: $grammarId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('questionType: $questionType, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
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
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    serverRevision,
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
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
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
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      )!,
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
  final int serverRevision;
  const LocalNote({
    required this.namespace,
    required this.ownerId,
    required this.noteId,
    required this.grammarId,
    required this.content,
    required this.updatedAt,
    this.deletedAt,
    required this.serverRevision,
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
    map['server_revision'] = Variable<int>(serverRevision);
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
      serverRevision: Value(serverRevision),
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
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
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
      'serverRevision': serializer.toJson<int>(serverRevision),
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
    int? serverRevision,
  }) => LocalNote(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    noteId: noteId ?? this.noteId,
    grammarId: grammarId ?? this.grammarId,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverRevision: serverRevision ?? this.serverRevision,
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
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
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
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision')
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
    serverRevision,
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
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision);
}

class LocalNotesCompanion extends UpdateCompanion<LocalNote> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> noteId;
  final Value<String> grammarId;
  final Value<String> content;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> serverRevision;
  final Value<int> rowid;
  const LocalNotesCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.content = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
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
    this.serverRevision = const Value.absent(),
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
    Expression<int>? serverRevision,
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
      if (serverRevision != null) 'server_revision': serverRevision,
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
    Value<int>? serverRevision,
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
      serverRevision: serverRevision ?? this.serverRevision,
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
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
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
          ..write('serverRevision: $serverRevision, ')
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
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('upsert'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictPayloadMeta = const VerificationMeta(
    'conflictPayload',
  );
  @override
  late final GeneratedColumn<String> conflictPayload = GeneratedColumn<String>(
    'conflict_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    namespace,
    ownerId,
    recordId,
    payload,
    entityTable,
    operationId,
    baseRevision,
    operationType,
    attempts,
    lastError,
    conflictPayload,
    createdAt,
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
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('conflict_payload')) {
      context.handle(
        _conflictPayloadMeta,
        conflictPayload.isAcceptableOrUnknown(
          data['conflict_payload']!,
          _conflictPayloadMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      conflictPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_payload'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
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
  final String operationId;
  final int? baseRevision;
  final String operationType;
  final int attempts;
  final String? lastError;
  final String? conflictPayload;
  final DateTime? createdAt;
  const SyncOutboxData({
    required this.sequence,
    required this.namespace,
    required this.ownerId,
    required this.recordId,
    required this.payload,
    required this.entityTable,
    required this.operationId,
    this.baseRevision,
    required this.operationType,
    required this.attempts,
    this.lastError,
    this.conflictPayload,
    this.createdAt,
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
    map['operation_id'] = Variable<String>(operationId);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    map['operation_type'] = Variable<String>(operationType);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || conflictPayload != null) {
      map['conflict_payload'] = Variable<String>(conflictPayload);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
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
      operationId: Value(operationId),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      operationType: Value(operationType),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      conflictPayload: conflictPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictPayload),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
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
      operationId: serializer.fromJson<String>(json['operationId']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      operationType: serializer.fromJson<String>(json['operationType']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      conflictPayload: serializer.fromJson<String?>(json['conflictPayload']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
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
      'operationId': serializer.toJson<String>(operationId),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'operationType': serializer.toJson<String>(operationType),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'conflictPayload': serializer.toJson<String?>(conflictPayload),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  SyncOutboxData copyWith({
    int? sequence,
    String? namespace,
    String? ownerId,
    String? recordId,
    String? payload,
    String? entityTable,
    String? operationId,
    Value<int?> baseRevision = const Value.absent(),
    String? operationType,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    Value<String?> conflictPayload = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => SyncOutboxData(
    sequence: sequence ?? this.sequence,
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    entityTable: entityTable ?? this.entityTable,
    operationId: operationId ?? this.operationId,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    operationType: operationType ?? this.operationType,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    conflictPayload: conflictPayload.present
        ? conflictPayload.value
        : this.conflictPayload,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
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
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      conflictPayload: data.conflictPayload.present
          ? data.conflictPayload.value
          : this.conflictPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
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
          ..write('entityTable: $entityTable, ')
          ..write('operationId: $operationId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('operationType: $operationType, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('conflictPayload: $conflictPayload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    namespace,
    ownerId,
    recordId,
    payload,
    entityTable,
    operationId,
    baseRevision,
    operationType,
    attempts,
    lastError,
    conflictPayload,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.sequence == this.sequence &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.entityTable == this.entityTable &&
          other.operationId == this.operationId &&
          other.baseRevision == this.baseRevision &&
          other.operationType == this.operationType &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.conflictPayload == this.conflictPayload &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> sequence;
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<String> entityTable;
  final Value<String> operationId;
  final Value<int?> baseRevision;
  final Value<String> operationType;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<String?> conflictPayload;
  final Value<DateTime?> createdAt;
  const SyncOutboxCompanion({
    this.sequence = const Value.absent(),
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.operationId = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.operationType = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.conflictPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.sequence = const Value.absent(),
    required String namespace,
    required String ownerId,
    required String recordId,
    required String payload,
    this.entityTable = const Value.absent(),
    this.operationId = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.operationType = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.conflictPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
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
    Expression<String>? operationId,
    Expression<int>? baseRevision,
    Expression<String>? operationType,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<String>? conflictPayload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (entityTable != null) 'entity_table': entityTable,
      if (operationId != null) 'operation_id': operationId,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (operationType != null) 'operation_type': operationType,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (conflictPayload != null) 'conflict_payload': conflictPayload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? sequence,
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? recordId,
    Value<String>? payload,
    Value<String>? entityTable,
    Value<String>? operationId,
    Value<int?>? baseRevision,
    Value<String>? operationType,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<String?>? conflictPayload,
    Value<DateTime?>? createdAt,
  }) {
    return SyncOutboxCompanion(
      sequence: sequence ?? this.sequence,
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      entityTable: entityTable ?? this.entityTable,
      operationId: operationId ?? this.operationId,
      baseRevision: baseRevision ?? this.baseRevision,
      operationType: operationType ?? this.operationType,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      conflictPayload: conflictPayload ?? this.conflictPayload,
      createdAt: createdAt ?? this.createdAt,
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
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (conflictPayload.present) {
      map['conflict_payload'] = Variable<String>(conflictPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('entityTable: $entityTable, ')
          ..write('operationId: $operationId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('operationType: $operationType, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('conflictPayload: $conflictPayload, ')
          ..write('createdAt: $createdAt')
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
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    ownerId,
    entityTable,
    recordId,
    payload,
    serverRevision,
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
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
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
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
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
  final int serverRevision;
  const PersonalRecord({
    required this.namespace,
    required this.ownerId,
    required this.entityTable,
    required this.recordId,
    required this.payload,
    required this.serverRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['entity_table'] = Variable<String>(entityTable);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['server_revision'] = Variable<int>(serverRevision);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      entityTable: Value(entityTable),
      recordId: Value(recordId),
      payload: Value(payload),
      serverRevision: Value(serverRevision),
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
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
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
      'serverRevision': serializer.toJson<int>(serverRevision),
    };
  }

  PersonalRecord copyWith({
    String? namespace,
    String? ownerId,
    String? entityTable,
    String? recordId,
    String? payload,
    int? serverRevision,
  }) => PersonalRecord(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    entityTable: entityTable ?? this.entityTable,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    serverRevision: serverRevision ?? this.serverRevision,
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
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('serverRevision: $serverRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    ownerId,
    entityTable,
    recordId,
    payload,
    serverRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.serverRevision == this.serverRevision);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> entityTable;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<int> serverRevision;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    required String namespace,
    required String ownerId,
    required String entityTable,
    required String recordId,
    required String payload,
    this.serverRevision = const Value.absent(),
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
    Expression<int>? serverRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (entityTable != null) 'entity_table': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? entityTable,
    Value<String>? recordId,
    Value<String>? payload,
    Value<int>? serverRevision,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      serverRevision: serverRevision ?? this.serverRevision,
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
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
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
          ..write('serverRevision: $serverRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPracticeAttemptsTable extends LocalPracticeAttempts
    with TableInfo<$LocalPracticeAttemptsTable, LocalPracticeAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPracticeAttemptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
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
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryOfMeta = const VerificationMeta(
    'retryOf',
  );
  @override
  late final GeneratedColumn<String> retryOf = GeneratedColumn<String>(
    'retry_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerTextMeta = const VerificationMeta(
    'answerText',
  );
  @override
  late final GeneratedColumn<String> answerText = GeneratedColumn<String>(
    'answer_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _selectedOptionIndexMeta =
      const VerificationMeta('selectedOptionIndex');
  @override
  late final GeneratedColumn<int> selectedOptionIndex = GeneratedColumn<int>(
    'selected_option_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isSkippedMeta = const VerificationMeta(
    'isSkipped',
  );
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
    'is_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFirstIndependentMeta =
      const VerificationMeta('isFirstIndependent');
  @override
  late final GeneratedColumn<bool> isFirstIndependent = GeneratedColumn<bool>(
    'is_first_independent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_first_independent" IN (0, 1))',
    ),
  );
  static const VerificationMeta _attemptedAtMeta = const VerificationMeta(
    'attemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> attemptedAt = GeneratedColumn<DateTime>(
    'attempted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    ownerId,
    attemptId,
    questionId,
    grammarId,
    contentVersion,
    sessionId,
    retryOf,
    answerText,
    selectedOptionIndex,
    isCorrect,
    isSkipped,
    isFirstIndependent,
    attemptedAt,
    serverReceivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_practice_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPracticeAttempt> instance, {
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
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('retry_of')) {
      context.handle(
        _retryOfMeta,
        retryOf.isAcceptableOrUnknown(data['retry_of']!, _retryOfMeta),
      );
    }
    if (data.containsKey('answer_text')) {
      context.handle(
        _answerTextMeta,
        answerText.isAcceptableOrUnknown(data['answer_text']!, _answerTextMeta),
      );
    }
    if (data.containsKey('selected_option_index')) {
      context.handle(
        _selectedOptionIndexMeta,
        selectedOptionIndex.isAcceptableOrUnknown(
          data['selected_option_index']!,
          _selectedOptionIndexMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('is_skipped')) {
      context.handle(
        _isSkippedMeta,
        isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta),
      );
    }
    if (data.containsKey('is_first_independent')) {
      context.handle(
        _isFirstIndependentMeta,
        isFirstIndependent.isAcceptableOrUnknown(
          data['is_first_independent']!,
          _isFirstIndependentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isFirstIndependentMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
        _attemptedAtMeta,
        attemptedAt.isAcceptableOrUnknown(
          data['attempted_at']!,
          _attemptedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptedAtMeta);
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, ownerId, attemptId};
  @override
  LocalPracticeAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPracticeAttempt(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      retryOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retry_of'],
      ),
      answerText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_text'],
      )!,
      selectedOptionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_option_index'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      isSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skipped'],
      )!,
      isFirstIndependent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_first_independent'],
      )!,
      attemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attempted_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
    );
  }

  @override
  $LocalPracticeAttemptsTable createAlias(String alias) {
    return $LocalPracticeAttemptsTable(attachedDatabase, alias);
  }
}

class LocalPracticeAttempt extends DataClass
    implements Insertable<LocalPracticeAttempt> {
  final String namespace;
  final String ownerId;
  final String attemptId;
  final String questionId;
  final String grammarId;
  final int contentVersion;
  final String sessionId;
  final String? retryOf;
  final String answerText;
  final int? selectedOptionIndex;
  final bool isCorrect;
  final bool isSkipped;
  final bool isFirstIndependent;
  final DateTime attemptedAt;
  final DateTime? serverReceivedAt;
  const LocalPracticeAttempt({
    required this.namespace,
    required this.ownerId,
    required this.attemptId,
    required this.questionId,
    required this.grammarId,
    required this.contentVersion,
    required this.sessionId,
    this.retryOf,
    required this.answerText,
    this.selectedOptionIndex,
    required this.isCorrect,
    required this.isSkipped,
    required this.isFirstIndependent,
    required this.attemptedAt,
    this.serverReceivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['attempt_id'] = Variable<String>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    map['grammar_id'] = Variable<String>(grammarId);
    map['content_version'] = Variable<int>(contentVersion);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || retryOf != null) {
      map['retry_of'] = Variable<String>(retryOf);
    }
    map['answer_text'] = Variable<String>(answerText);
    if (!nullToAbsent || selectedOptionIndex != null) {
      map['selected_option_index'] = Variable<int>(selectedOptionIndex);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['is_skipped'] = Variable<bool>(isSkipped);
    map['is_first_independent'] = Variable<bool>(isFirstIndependent);
    map['attempted_at'] = Variable<DateTime>(attemptedAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    return map;
  }

  LocalPracticeAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LocalPracticeAttemptsCompanion(
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      grammarId: Value(grammarId),
      contentVersion: Value(contentVersion),
      sessionId: Value(sessionId),
      retryOf: retryOf == null && nullToAbsent
          ? const Value.absent()
          : Value(retryOf),
      answerText: Value(answerText),
      selectedOptionIndex: selectedOptionIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedOptionIndex),
      isCorrect: Value(isCorrect),
      isSkipped: Value(isSkipped),
      isFirstIndependent: Value(isFirstIndependent),
      attemptedAt: Value(attemptedAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
    );
  }

  factory LocalPracticeAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPracticeAttempt(
      namespace: serializer.fromJson<String>(json['namespace']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      contentVersion: serializer.fromJson<int>(json['contentVersion']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      retryOf: serializer.fromJson<String?>(json['retryOf']),
      answerText: serializer.fromJson<String>(json['answerText']),
      selectedOptionIndex: serializer.fromJson<int?>(
        json['selectedOptionIndex'],
      ),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
      isFirstIndependent: serializer.fromJson<bool>(json['isFirstIndependent']),
      attemptedAt: serializer.fromJson<DateTime>(json['attemptedAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'ownerId': serializer.toJson<String>(ownerId),
      'attemptId': serializer.toJson<String>(attemptId),
      'questionId': serializer.toJson<String>(questionId),
      'grammarId': serializer.toJson<String>(grammarId),
      'contentVersion': serializer.toJson<int>(contentVersion),
      'sessionId': serializer.toJson<String>(sessionId),
      'retryOf': serializer.toJson<String?>(retryOf),
      'answerText': serializer.toJson<String>(answerText),
      'selectedOptionIndex': serializer.toJson<int?>(selectedOptionIndex),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'isSkipped': serializer.toJson<bool>(isSkipped),
      'isFirstIndependent': serializer.toJson<bool>(isFirstIndependent),
      'attemptedAt': serializer.toJson<DateTime>(attemptedAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
    };
  }

  LocalPracticeAttempt copyWith({
    String? namespace,
    String? ownerId,
    String? attemptId,
    String? questionId,
    String? grammarId,
    int? contentVersion,
    String? sessionId,
    Value<String?> retryOf = const Value.absent(),
    String? answerText,
    Value<int?> selectedOptionIndex = const Value.absent(),
    bool? isCorrect,
    bool? isSkipped,
    bool? isFirstIndependent,
    DateTime? attemptedAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
  }) => LocalPracticeAttempt(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    grammarId: grammarId ?? this.grammarId,
    contentVersion: contentVersion ?? this.contentVersion,
    sessionId: sessionId ?? this.sessionId,
    retryOf: retryOf.present ? retryOf.value : this.retryOf,
    answerText: answerText ?? this.answerText,
    selectedOptionIndex: selectedOptionIndex.present
        ? selectedOptionIndex.value
        : this.selectedOptionIndex,
    isCorrect: isCorrect ?? this.isCorrect,
    isSkipped: isSkipped ?? this.isSkipped,
    isFirstIndependent: isFirstIndependent ?? this.isFirstIndependent,
    attemptedAt: attemptedAt ?? this.attemptedAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
  );
  LocalPracticeAttempt copyWithCompanion(LocalPracticeAttemptsCompanion data) {
    return LocalPracticeAttempt(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      retryOf: data.retryOf.present ? data.retryOf.value : this.retryOf,
      answerText: data.answerText.present
          ? data.answerText.value
          : this.answerText,
      selectedOptionIndex: data.selectedOptionIndex.present
          ? data.selectedOptionIndex.value
          : this.selectedOptionIndex,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
      isFirstIndependent: data.isFirstIndependent.present
          ? data.isFirstIndependent.value
          : this.isFirstIndependent,
      attemptedAt: data.attemptedAt.present
          ? data.attemptedAt.value
          : this.attemptedAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeAttempt(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('grammarId: $grammarId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('sessionId: $sessionId, ')
          ..write('retryOf: $retryOf, ')
          ..write('answerText: $answerText, ')
          ..write('selectedOptionIndex: $selectedOptionIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('isFirstIndependent: $isFirstIndependent, ')
          ..write('attemptedAt: $attemptedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    ownerId,
    attemptId,
    questionId,
    grammarId,
    contentVersion,
    sessionId,
    retryOf,
    answerText,
    selectedOptionIndex,
    isCorrect,
    isSkipped,
    isFirstIndependent,
    attemptedAt,
    serverReceivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPracticeAttempt &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.grammarId == this.grammarId &&
          other.contentVersion == this.contentVersion &&
          other.sessionId == this.sessionId &&
          other.retryOf == this.retryOf &&
          other.answerText == this.answerText &&
          other.selectedOptionIndex == this.selectedOptionIndex &&
          other.isCorrect == this.isCorrect &&
          other.isSkipped == this.isSkipped &&
          other.isFirstIndependent == this.isFirstIndependent &&
          other.attemptedAt == this.attemptedAt &&
          other.serverReceivedAt == this.serverReceivedAt);
}

class LocalPracticeAttemptsCompanion
    extends UpdateCompanion<LocalPracticeAttempt> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> attemptId;
  final Value<String> questionId;
  final Value<String> grammarId;
  final Value<int> contentVersion;
  final Value<String> sessionId;
  final Value<String?> retryOf;
  final Value<String> answerText;
  final Value<int?> selectedOptionIndex;
  final Value<bool> isCorrect;
  final Value<bool> isSkipped;
  final Value<bool> isFirstIndependent;
  final Value<DateTime> attemptedAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<int> rowid;
  const LocalPracticeAttemptsCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.retryOf = const Value.absent(),
    this.answerText = const Value.absent(),
    this.selectedOptionIndex = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.isSkipped = const Value.absent(),
    this.isFirstIndependent = const Value.absent(),
    this.attemptedAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPracticeAttemptsCompanion.insert({
    required String namespace,
    required String ownerId,
    required String attemptId,
    required String questionId,
    required String grammarId,
    required int contentVersion,
    required String sessionId,
    this.retryOf = const Value.absent(),
    this.answerText = const Value.absent(),
    this.selectedOptionIndex = const Value.absent(),
    required bool isCorrect,
    this.isSkipped = const Value.absent(),
    required bool isFirstIndependent,
    required DateTime attemptedAt,
    this.serverReceivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       ownerId = Value(ownerId),
       attemptId = Value(attemptId),
       questionId = Value(questionId),
       grammarId = Value(grammarId),
       contentVersion = Value(contentVersion),
       sessionId = Value(sessionId),
       isCorrect = Value(isCorrect),
       isFirstIndependent = Value(isFirstIndependent),
       attemptedAt = Value(attemptedAt);
  static Insertable<LocalPracticeAttempt> custom({
    Expression<String>? namespace,
    Expression<String>? ownerId,
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<String>? grammarId,
    Expression<int>? contentVersion,
    Expression<String>? sessionId,
    Expression<String>? retryOf,
    Expression<String>? answerText,
    Expression<int>? selectedOptionIndex,
    Expression<bool>? isCorrect,
    Expression<bool>? isSkipped,
    Expression<bool>? isFirstIndependent,
    Expression<DateTime>? attemptedAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (grammarId != null) 'grammar_id': grammarId,
      if (contentVersion != null) 'content_version': contentVersion,
      if (sessionId != null) 'session_id': sessionId,
      if (retryOf != null) 'retry_of': retryOf,
      if (answerText != null) 'answer_text': answerText,
      if (selectedOptionIndex != null)
        'selected_option_index': selectedOptionIndex,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (isSkipped != null) 'is_skipped': isSkipped,
      if (isFirstIndependent != null)
        'is_first_independent': isFirstIndependent,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPracticeAttemptsCompanion copyWith({
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? attemptId,
    Value<String>? questionId,
    Value<String>? grammarId,
    Value<int>? contentVersion,
    Value<String>? sessionId,
    Value<String?>? retryOf,
    Value<String>? answerText,
    Value<int?>? selectedOptionIndex,
    Value<bool>? isCorrect,
    Value<bool>? isSkipped,
    Value<bool>? isFirstIndependent,
    Value<DateTime>? attemptedAt,
    Value<DateTime?>? serverReceivedAt,
    Value<int>? rowid,
  }) {
    return LocalPracticeAttemptsCompanion(
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      grammarId: grammarId ?? this.grammarId,
      contentVersion: contentVersion ?? this.contentVersion,
      sessionId: sessionId ?? this.sessionId,
      retryOf: retryOf ?? this.retryOf,
      answerText: answerText ?? this.answerText,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      isSkipped: isSkipped ?? this.isSkipped,
      isFirstIndependent: isFirstIndependent ?? this.isFirstIndependent,
      attemptedAt: attemptedAt ?? this.attemptedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
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
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (retryOf.present) {
      map['retry_of'] = Variable<String>(retryOf.value);
    }
    if (answerText.present) {
      map['answer_text'] = Variable<String>(answerText.value);
    }
    if (selectedOptionIndex.present) {
      map['selected_option_index'] = Variable<int>(selectedOptionIndex.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    if (isFirstIndependent.present) {
      map['is_first_independent'] = Variable<bool>(isFirstIndependent.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<DateTime>(attemptedAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPracticeAttemptsCompanion(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('grammarId: $grammarId, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('sessionId: $sessionId, ')
          ..write('retryOf: $retryOf, ')
          ..write('answerText: $answerText, ')
          ..write('selectedOptionIndex: $selectedOptionIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('isFirstIndependent: $isFirstIndependent, ')
          ..write('attemptedAt: $attemptedAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalReviewStatesTable extends LocalReviewStates
    with TableInfo<$LocalReviewStatesTable, LocalReviewState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReviewStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<int> stage = GeneratedColumn<int>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<int> algorithmVersion = GeneratedColumn<int>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastAttemptIdMeta = const VerificationMeta(
    'lastAttemptId',
  );
  @override
  late final GeneratedColumn<String> lastAttemptId = GeneratedColumn<String>(
    'last_attempt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTentativeMeta = const VerificationMeta(
    'isTentative',
  );
  @override
  late final GeneratedColumn<bool> isTentative = GeneratedColumn<bool>(
    'is_tentative',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tentative" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    ownerId,
    grammarId,
    stage,
    dueAt,
    algorithmVersion,
    lastAttemptId,
    isTentative,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_review_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReviewState> instance, {
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
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_id')) {
      context.handle(
        _lastAttemptIdMeta,
        lastAttemptId.isAcceptableOrUnknown(
          data['last_attempt_id']!,
          _lastAttemptIdMeta,
        ),
      );
    }
    if (data.containsKey('is_tentative')) {
      context.handle(
        _isTentativeMeta,
        isTentative.isAcceptableOrUnknown(
          data['is_tentative']!,
          _isTentativeMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, ownerId, grammarId};
  @override
  LocalReviewState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReviewState(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}algorithm_version'],
      )!,
      lastAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_attempt_id'],
      ),
      isTentative: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tentative'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalReviewStatesTable createAlias(String alias) {
    return $LocalReviewStatesTable(attachedDatabase, alias);
  }
}

class LocalReviewState extends DataClass
    implements Insertable<LocalReviewState> {
  final String namespace;
  final String ownerId;
  final String grammarId;
  final int stage;
  final DateTime? dueAt;
  final int algorithmVersion;
  final String? lastAttemptId;
  final bool isTentative;
  final DateTime updatedAt;
  const LocalReviewState({
    required this.namespace,
    required this.ownerId,
    required this.grammarId,
    required this.stage,
    this.dueAt,
    required this.algorithmVersion,
    this.lastAttemptId,
    required this.isTentative,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['owner_id'] = Variable<String>(ownerId);
    map['grammar_id'] = Variable<String>(grammarId);
    map['stage'] = Variable<int>(stage);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['algorithm_version'] = Variable<int>(algorithmVersion);
    if (!nullToAbsent || lastAttemptId != null) {
      map['last_attempt_id'] = Variable<String>(lastAttemptId);
    }
    map['is_tentative'] = Variable<bool>(isTentative);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalReviewStatesCompanion toCompanion(bool nullToAbsent) {
    return LocalReviewStatesCompanion(
      namespace: Value(namespace),
      ownerId: Value(ownerId),
      grammarId: Value(grammarId),
      stage: Value(stage),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      algorithmVersion: Value(algorithmVersion),
      lastAttemptId: lastAttemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptId),
      isTentative: Value(isTentative),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalReviewState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReviewState(
      namespace: serializer.fromJson<String>(json['namespace']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      grammarId: serializer.fromJson<String>(json['grammarId']),
      stage: serializer.fromJson<int>(json['stage']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      algorithmVersion: serializer.fromJson<int>(json['algorithmVersion']),
      lastAttemptId: serializer.fromJson<String?>(json['lastAttemptId']),
      isTentative: serializer.fromJson<bool>(json['isTentative']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'ownerId': serializer.toJson<String>(ownerId),
      'grammarId': serializer.toJson<String>(grammarId),
      'stage': serializer.toJson<int>(stage),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'algorithmVersion': serializer.toJson<int>(algorithmVersion),
      'lastAttemptId': serializer.toJson<String?>(lastAttemptId),
      'isTentative': serializer.toJson<bool>(isTentative),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalReviewState copyWith({
    String? namespace,
    String? ownerId,
    String? grammarId,
    int? stage,
    Value<DateTime?> dueAt = const Value.absent(),
    int? algorithmVersion,
    Value<String?> lastAttemptId = const Value.absent(),
    bool? isTentative,
    DateTime? updatedAt,
  }) => LocalReviewState(
    namespace: namespace ?? this.namespace,
    ownerId: ownerId ?? this.ownerId,
    grammarId: grammarId ?? this.grammarId,
    stage: stage ?? this.stage,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    lastAttemptId: lastAttemptId.present
        ? lastAttemptId.value
        : this.lastAttemptId,
    isTentative: isTentative ?? this.isTentative,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalReviewState copyWithCompanion(LocalReviewStatesCompanion data) {
    return LocalReviewState(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      stage: data.stage.present ? data.stage.value : this.stage,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      lastAttemptId: data.lastAttemptId.present
          ? data.lastAttemptId.value
          : this.lastAttemptId,
      isTentative: data.isTentative.present
          ? data.isTentative.value
          : this.isTentative,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReviewState(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('grammarId: $grammarId, ')
          ..write('stage: $stage, ')
          ..write('dueAt: $dueAt, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('lastAttemptId: $lastAttemptId, ')
          ..write('isTentative: $isTentative, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    ownerId,
    grammarId,
    stage,
    dueAt,
    algorithmVersion,
    lastAttemptId,
    isTentative,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReviewState &&
          other.namespace == this.namespace &&
          other.ownerId == this.ownerId &&
          other.grammarId == this.grammarId &&
          other.stage == this.stage &&
          other.dueAt == this.dueAt &&
          other.algorithmVersion == this.algorithmVersion &&
          other.lastAttemptId == this.lastAttemptId &&
          other.isTentative == this.isTentative &&
          other.updatedAt == this.updatedAt);
}

class LocalReviewStatesCompanion extends UpdateCompanion<LocalReviewState> {
  final Value<String> namespace;
  final Value<String> ownerId;
  final Value<String> grammarId;
  final Value<int> stage;
  final Value<DateTime?> dueAt;
  final Value<int> algorithmVersion;
  final Value<String?> lastAttemptId;
  final Value<bool> isTentative;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalReviewStatesCompanion({
    this.namespace = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.stage = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.lastAttemptId = const Value.absent(),
    this.isTentative = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalReviewStatesCompanion.insert({
    required String namespace,
    required String ownerId,
    required String grammarId,
    this.stage = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.lastAttemptId = const Value.absent(),
    this.isTentative = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       ownerId = Value(ownerId),
       grammarId = Value(grammarId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalReviewState> custom({
    Expression<String>? namespace,
    Expression<String>? ownerId,
    Expression<String>? grammarId,
    Expression<int>? stage,
    Expression<DateTime>? dueAt,
    Expression<int>? algorithmVersion,
    Expression<String>? lastAttemptId,
    Expression<bool>? isTentative,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (ownerId != null) 'owner_id': ownerId,
      if (grammarId != null) 'grammar_id': grammarId,
      if (stage != null) 'stage': stage,
      if (dueAt != null) 'due_at': dueAt,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (lastAttemptId != null) 'last_attempt_id': lastAttemptId,
      if (isTentative != null) 'is_tentative': isTentative,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalReviewStatesCompanion copyWith({
    Value<String>? namespace,
    Value<String>? ownerId,
    Value<String>? grammarId,
    Value<int>? stage,
    Value<DateTime?>? dueAt,
    Value<int>? algorithmVersion,
    Value<String?>? lastAttemptId,
    Value<bool>? isTentative,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalReviewStatesCompanion(
      namespace: namespace ?? this.namespace,
      ownerId: ownerId ?? this.ownerId,
      grammarId: grammarId ?? this.grammarId,
      stage: stage ?? this.stage,
      dueAt: dueAt ?? this.dueAt,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      lastAttemptId: lastAttemptId ?? this.lastAttemptId,
      isTentative: isTentative ?? this.isTentative,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (grammarId.present) {
      map['grammar_id'] = Variable<String>(grammarId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<int>(stage.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<int>(algorithmVersion.value);
    }
    if (lastAttemptId.present) {
      map['last_attempt_id'] = Variable<String>(lastAttemptId.value);
    }
    if (isTentative.present) {
      map['is_tentative'] = Variable<bool>(isTentative.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReviewStatesCompanion(')
          ..write('namespace: $namespace, ')
          ..write('ownerId: $ownerId, ')
          ..write('grammarId: $grammarId, ')
          ..write('stage: $stage, ')
          ..write('dueAt: $dueAt, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('lastAttemptId: $lastAttemptId, ')
          ..write('isTentative: $isTentative, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedGrammarTable cachedGrammar = $CachedGrammarTable(this);
  late final $CachedQuestionsTable cachedQuestions = $CachedQuestionsTable(
    this,
  );
  late final $LocalNotesTable localNotes = $LocalNotesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $LocalPracticeAttemptsTable localPracticeAttempts =
      $LocalPracticeAttemptsTable(this);
  late final $LocalReviewStatesTable localReviewStates =
      $LocalReviewStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedGrammar,
    cachedQuestions,
    localNotes,
    syncOutbox,
    personalRecords,
    localPracticeAttempts,
    localReviewStates,
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
typedef $$CachedQuestionsTableCreateCompanionBuilder =
    CachedQuestionsCompanion Function({
      required String namespace,
      required String questionId,
      required String grammarId,
      required int contentVersion,
      required String questionType,
      required String payload,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CachedQuestionsTableUpdateCompanionBuilder =
    CachedQuestionsCompanion Function({
      Value<String> namespace,
      Value<String> questionId,
      Value<String> grammarId,
      Value<int> contentVersion,
      Value<String> questionType,
      Value<String> payload,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CachedQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableFilterComposer({
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

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedQuestionsTable> {
  $$CachedQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedQuestionsTable,
          CachedQuestion,
          $$CachedQuestionsTableFilterComposer,
          $$CachedQuestionsTableOrderingComposer,
          $$CachedQuestionsTableAnnotationComposer,
          $$CachedQuestionsTableCreateCompanionBuilder,
          $$CachedQuestionsTableUpdateCompanionBuilder,
          (
            CachedQuestion,
            BaseReferences<
              _$AppDatabase,
              $CachedQuestionsTable,
              CachedQuestion
            >,
          ),
          CachedQuestion,
          PrefetchHooks Function()
        > {
  $$CachedQuestionsTableTableManager(
    _$AppDatabase db,
    $CachedQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String> questionType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedQuestionsCompanion(
                namespace: namespace,
                questionId: questionId,
                grammarId: grammarId,
                contentVersion: contentVersion,
                questionType: questionType,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String questionId,
                required String grammarId,
                required int contentVersion,
                required String questionType,
                required String payload,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedQuestionsCompanion.insert(
                namespace: namespace,
                questionId: questionId,
                grammarId: grammarId,
                contentVersion: contentVersion,
                questionType: questionType,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedQuestionsTable,
      CachedQuestion,
      $$CachedQuestionsTableFilterComposer,
      $$CachedQuestionsTableOrderingComposer,
      $$CachedQuestionsTableAnnotationComposer,
      $$CachedQuestionsTableCreateCompanionBuilder,
      $$CachedQuestionsTableUpdateCompanionBuilder,
      (
        CachedQuestion,
        BaseReferences<_$AppDatabase, $CachedQuestionsTable, CachedQuestion>,
      ),
      CachedQuestion,
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
      Value<int> serverRevision,
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
      Value<int> serverRevision,
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

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
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

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
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

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );
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
                Value<int> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNotesCompanion(
                namespace: namespace,
                ownerId: ownerId,
                noteId: noteId,
                grammarId: grammarId,
                content: content,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverRevision: serverRevision,
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
                Value<int> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNotesCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                noteId: noteId,
                grammarId: grammarId,
                content: content,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverRevision: serverRevision,
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
      Value<String> operationId,
      Value<int?> baseRevision,
      Value<String> operationType,
      Value<int> attempts,
      Value<String?> lastError,
      Value<String?> conflictPayload,
      Value<DateTime?> createdAt,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> sequence,
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> recordId,
      Value<String> payload,
      Value<String> entityTable,
      Value<String> operationId,
      Value<int?> baseRevision,
      Value<String> operationType,
      Value<int> attempts,
      Value<String?> lastError,
      Value<String?> conflictPayload,
      Value<DateTime?> createdAt,
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

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
                Value<String> operationId = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> conflictPayload = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => SyncOutboxCompanion(
                sequence: sequence,
                namespace: namespace,
                ownerId: ownerId,
                recordId: recordId,
                payload: payload,
                entityTable: entityTable,
                operationId: operationId,
                baseRevision: baseRevision,
                operationType: operationType,
                attempts: attempts,
                lastError: lastError,
                conflictPayload: conflictPayload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                required String namespace,
                required String ownerId,
                required String recordId,
                required String payload,
                Value<String> entityTable = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> conflictPayload = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                sequence: sequence,
                namespace: namespace,
                ownerId: ownerId,
                recordId: recordId,
                payload: payload,
                entityTable: entityTable,
                operationId: operationId,
                baseRevision: baseRevision,
                operationType: operationType,
                attempts: attempts,
                lastError: lastError,
                conflictPayload: conflictPayload,
                createdAt: createdAt,
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
      Value<int> serverRevision,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> entityTable,
      Value<String> recordId,
      Value<String> payload,
      Value<int> serverRevision,
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

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
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

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
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

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );
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
                Value<int> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                namespace: namespace,
                ownerId: ownerId,
                entityTable: entityTable,
                recordId: recordId,
                payload: payload,
                serverRevision: serverRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String ownerId,
                required String entityTable,
                required String recordId,
                required String payload,
                Value<int> serverRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                entityTable: entityTable,
                recordId: recordId,
                payload: payload,
                serverRevision: serverRevision,
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
typedef $$LocalPracticeAttemptsTableCreateCompanionBuilder =
    LocalPracticeAttemptsCompanion Function({
      required String namespace,
      required String ownerId,
      required String attemptId,
      required String questionId,
      required String grammarId,
      required int contentVersion,
      required String sessionId,
      Value<String?> retryOf,
      Value<String> answerText,
      Value<int?> selectedOptionIndex,
      required bool isCorrect,
      Value<bool> isSkipped,
      required bool isFirstIndependent,
      required DateTime attemptedAt,
      Value<DateTime?> serverReceivedAt,
      Value<int> rowid,
    });
typedef $$LocalPracticeAttemptsTableUpdateCompanionBuilder =
    LocalPracticeAttemptsCompanion Function({
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> attemptId,
      Value<String> questionId,
      Value<String> grammarId,
      Value<int> contentVersion,
      Value<String> sessionId,
      Value<String?> retryOf,
      Value<String> answerText,
      Value<int?> selectedOptionIndex,
      Value<bool> isCorrect,
      Value<bool> isSkipped,
      Value<bool> isFirstIndependent,
      Value<DateTime> attemptedAt,
      Value<DateTime?> serverReceivedAt,
      Value<int> rowid,
    });

class $$LocalPracticeAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPracticeAttemptsTable> {
  $$LocalPracticeAttemptsTableFilterComposer({
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

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retryOf => $composableBuilder(
    column: $table.retryOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFirstIndependent => $composableBuilder(
    column: $table.isFirstIndependent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPracticeAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPracticeAttemptsTable> {
  $$LocalPracticeAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retryOf => $composableBuilder(
    column: $table.retryOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFirstIndependent => $composableBuilder(
    column: $table.isFirstIndependent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPracticeAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPracticeAttemptsTable> {
  $$LocalPracticeAttemptsTableAnnotationComposer({
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

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get retryOf =>
      $composableBuilder(column: $table.retryOf, builder: (column) => column);

  GeneratedColumn<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  GeneratedColumn<bool> get isFirstIndependent => $composableBuilder(
    column: $table.isFirstIndependent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );
}

class $$LocalPracticeAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPracticeAttemptsTable,
          LocalPracticeAttempt,
          $$LocalPracticeAttemptsTableFilterComposer,
          $$LocalPracticeAttemptsTableOrderingComposer,
          $$LocalPracticeAttemptsTableAnnotationComposer,
          $$LocalPracticeAttemptsTableCreateCompanionBuilder,
          $$LocalPracticeAttemptsTableUpdateCompanionBuilder,
          (
            LocalPracticeAttempt,
            BaseReferences<
              _$AppDatabase,
              $LocalPracticeAttemptsTable,
              LocalPracticeAttempt
            >,
          ),
          LocalPracticeAttempt,
          PrefetchHooks Function()
        > {
  $$LocalPracticeAttemptsTableTableManager(
    _$AppDatabase db,
    $LocalPracticeAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPracticeAttemptsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalPracticeAttemptsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPracticeAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> retryOf = const Value.absent(),
                Value<String> answerText = const Value.absent(),
                Value<int?> selectedOptionIndex = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
                Value<bool> isFirstIndependent = const Value.absent(),
                Value<DateTime> attemptedAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeAttemptsCompanion(
                namespace: namespace,
                ownerId: ownerId,
                attemptId: attemptId,
                questionId: questionId,
                grammarId: grammarId,
                contentVersion: contentVersion,
                sessionId: sessionId,
                retryOf: retryOf,
                answerText: answerText,
                selectedOptionIndex: selectedOptionIndex,
                isCorrect: isCorrect,
                isSkipped: isSkipped,
                isFirstIndependent: isFirstIndependent,
                attemptedAt: attemptedAt,
                serverReceivedAt: serverReceivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String ownerId,
                required String attemptId,
                required String questionId,
                required String grammarId,
                required int contentVersion,
                required String sessionId,
                Value<String?> retryOf = const Value.absent(),
                Value<String> answerText = const Value.absent(),
                Value<int?> selectedOptionIndex = const Value.absent(),
                required bool isCorrect,
                Value<bool> isSkipped = const Value.absent(),
                required bool isFirstIndependent,
                required DateTime attemptedAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPracticeAttemptsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                attemptId: attemptId,
                questionId: questionId,
                grammarId: grammarId,
                contentVersion: contentVersion,
                sessionId: sessionId,
                retryOf: retryOf,
                answerText: answerText,
                selectedOptionIndex: selectedOptionIndex,
                isCorrect: isCorrect,
                isSkipped: isSkipped,
                isFirstIndependent: isFirstIndependent,
                attemptedAt: attemptedAt,
                serverReceivedAt: serverReceivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPracticeAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPracticeAttemptsTable,
      LocalPracticeAttempt,
      $$LocalPracticeAttemptsTableFilterComposer,
      $$LocalPracticeAttemptsTableOrderingComposer,
      $$LocalPracticeAttemptsTableAnnotationComposer,
      $$LocalPracticeAttemptsTableCreateCompanionBuilder,
      $$LocalPracticeAttemptsTableUpdateCompanionBuilder,
      (
        LocalPracticeAttempt,
        BaseReferences<
          _$AppDatabase,
          $LocalPracticeAttemptsTable,
          LocalPracticeAttempt
        >,
      ),
      LocalPracticeAttempt,
      PrefetchHooks Function()
    >;
typedef $$LocalReviewStatesTableCreateCompanionBuilder =
    LocalReviewStatesCompanion Function({
      required String namespace,
      required String ownerId,
      required String grammarId,
      Value<int> stage,
      Value<DateTime?> dueAt,
      Value<int> algorithmVersion,
      Value<String?> lastAttemptId,
      Value<bool> isTentative,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalReviewStatesTableUpdateCompanionBuilder =
    LocalReviewStatesCompanion Function({
      Value<String> namespace,
      Value<String> ownerId,
      Value<String> grammarId,
      Value<int> stage,
      Value<DateTime?> dueAt,
      Value<int> algorithmVersion,
      Value<String?> lastAttemptId,
      Value<bool> isTentative,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalReviewStatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalReviewStatesTable> {
  $$LocalReviewStatesTableFilterComposer({
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

  ColumnFilters<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAttemptId => $composableBuilder(
    column: $table.lastAttemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTentative => $composableBuilder(
    column: $table.isTentative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalReviewStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalReviewStatesTable> {
  $$LocalReviewStatesTableOrderingComposer({
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

  ColumnOrderings<String> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAttemptId => $composableBuilder(
    column: $table.lastAttemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTentative => $composableBuilder(
    column: $table.isTentative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalReviewStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalReviewStatesTable> {
  $$LocalReviewStatesTableAnnotationComposer({
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

  GeneratedColumn<String> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<int> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastAttemptId => $composableBuilder(
    column: $table.lastAttemptId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTentative => $composableBuilder(
    column: $table.isTentative,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalReviewStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalReviewStatesTable,
          LocalReviewState,
          $$LocalReviewStatesTableFilterComposer,
          $$LocalReviewStatesTableOrderingComposer,
          $$LocalReviewStatesTableAnnotationComposer,
          $$LocalReviewStatesTableCreateCompanionBuilder,
          $$LocalReviewStatesTableUpdateCompanionBuilder,
          (
            LocalReviewState,
            BaseReferences<
              _$AppDatabase,
              $LocalReviewStatesTable,
              LocalReviewState
            >,
          ),
          LocalReviewState,
          PrefetchHooks Function()
        > {
  $$LocalReviewStatesTableTableManager(
    _$AppDatabase db,
    $LocalReviewStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReviewStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReviewStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReviewStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> grammarId = const Value.absent(),
                Value<int> stage = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<int> algorithmVersion = const Value.absent(),
                Value<String?> lastAttemptId = const Value.absent(),
                Value<bool> isTentative = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReviewStatesCompanion(
                namespace: namespace,
                ownerId: ownerId,
                grammarId: grammarId,
                stage: stage,
                dueAt: dueAt,
                algorithmVersion: algorithmVersion,
                lastAttemptId: lastAttemptId,
                isTentative: isTentative,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String ownerId,
                required String grammarId,
                Value<int> stage = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<int> algorithmVersion = const Value.absent(),
                Value<String?> lastAttemptId = const Value.absent(),
                Value<bool> isTentative = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalReviewStatesCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                grammarId: grammarId,
                stage: stage,
                dueAt: dueAt,
                algorithmVersion: algorithmVersion,
                lastAttemptId: lastAttemptId,
                isTentative: isTentative,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalReviewStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalReviewStatesTable,
      LocalReviewState,
      $$LocalReviewStatesTableFilterComposer,
      $$LocalReviewStatesTableOrderingComposer,
      $$LocalReviewStatesTableAnnotationComposer,
      $$LocalReviewStatesTableCreateCompanionBuilder,
      $$LocalReviewStatesTableUpdateCompanionBuilder,
      (
        LocalReviewState,
        BaseReferences<
          _$AppDatabase,
          $LocalReviewStatesTable,
          LocalReviewState
        >,
      ),
      LocalReviewState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedGrammarTableTableManager get cachedGrammar =>
      $$CachedGrammarTableTableManager(_db, _db.cachedGrammar);
  $$CachedQuestionsTableTableManager get cachedQuestions =>
      $$CachedQuestionsTableTableManager(_db, _db.cachedQuestions);
  $$LocalNotesTableTableManager get localNotes =>
      $$LocalNotesTableTableManager(_db, _db.localNotes);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$LocalPracticeAttemptsTableTableManager get localPracticeAttempts =>
      $$LocalPracticeAttemptsTableTableManager(_db, _db.localPracticeAttempts);
  $$LocalReviewStatesTableTableManager get localReviewStates =>
      $$LocalReviewStatesTableTableManager(_db, _db.localReviewStates);
}
