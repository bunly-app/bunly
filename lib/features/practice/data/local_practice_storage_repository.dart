import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/practice_storage.dart';

CuratedPracticeQuestion practiceQuestionFromJson(Map<String, dynamic> row) {
  final options = (row['options'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList();
  final accepted = (row['accepted_answers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList();
  final rawType =
      (row['question_type'] ?? row['type']) as String? ??
      (throw const FormatException('Thiếu question_type'));
  return CuratedPracticeQuestion(
    id: row['id'] as String,
    grammarId: row['grammar_id'] as String,
    contentVersion: (row['content_version'] as num?)?.toInt() ?? 1,
    type: PracticeBankType.parse(rawType),
    prompt: row['prompt'] as String,
    options: options ?? const [],
    correctOptionIndex: (row['correct_option_index'] as num?)?.toInt(),
    acceptedAnswers: accepted ?? const [],
    normalization: row['normalization'] as String? ?? 'trim_only',
    explanationVi: row['explanation_vi'] as String,
    updatedAt: row['updated_at'] == null
        ? null
        : DateTime.parse(row['updated_at'] as String).toUtc(),
  );
}

Map<String, dynamic> practiceQuestionToJson(CuratedPracticeQuestion q) => {
  'id': q.id,
  'grammar_id': q.grammarId,
  'content_version': q.contentVersion,
  'question_type': q.type.value,
  'prompt': q.prompt,
  'options': q.type == PracticeBankType.mcq ? q.options : null,
  'correct_option_index': q.type == PracticeBankType.mcq
      ? q.correctOptionIndex
      : null,
  'accepted_answers': q.type == PracticeBankType.cloze
      ? q.acceptedAnswers
      : null,
  'normalization': q.normalization,
  'explanation_vi': q.explanationVi,
  'updated_at': q.updatedAt?.toUtc().toIso8601String(),
};

class LocalPracticeStorageRepository implements PracticeStorageRepository {
  LocalPracticeStorageRepository(
    this.database, {
    required this.namespace,
    required this.ownerId,
    required this.queueRemote,
  });

  final AppDatabase database;
  final String namespace;
  final String ownerId;
  final bool queueRemote;

  @override
  Future<void> replaceCachedQuestions(
    List<CuratedPracticeQuestion> questions,
  ) => database.transaction(() async {
    await (database.delete(
      database.cachedQuestions,
    )..where((t) => t.namespace.equals(namespace))).go();
    if (questions.isEmpty) return;
    await database.batch(
      (batch) => batch.insertAll(
        database.cachedQuestions,
        questions
            .map(
              (q) => CachedQuestionsCompanion.insert(
                namespace: namespace,
                questionId: q.id,
                grammarId: q.grammarId,
                contentVersion: q.contentVersion,
                questionType: q.type.value,
                payload: jsonEncode(practiceQuestionToJson(q)),
                updatedAt: Value(q.updatedAt?.toUtc()),
              ),
            )
            .toList(),
      ),
    );
  });

  @override
  Future<List<CuratedPracticeQuestion>> loadCachedQuestions({
    String? grammarId,
  }) async {
    final rows =
        await (database.select(database.cachedQuestions)
              ..where(
                (t) =>
                    t.namespace.equals(namespace) &
                    (grammarId == null
                        ? const Constant(true)
                        : t.grammarId.equals(grammarId)),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.questionId)]))
            .get();
    return rows
        .map(
          (row) => practiceQuestionFromJson(
            jsonDecode(row.payload) as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> recordAttempt(PracticeAttemptEntry attempt) =>
      database.transaction(() async {
        final existing =
            await (database.select(database.localPracticeAttempts)..where(
                  (t) =>
                      t.namespace.equals(namespace) &
                      t.ownerId.equals(ownerId) &
                      t.attemptId.equals(attempt.attemptId),
                ))
                .getSingleOrNull();
        if (existing != null) return;

        if (attempt.isFirstIndependent) {
          final duplicateIndependent =
              await (database.select(database.localPracticeAttempts)..where(
                    (t) =>
                        t.namespace.equals(namespace) &
                        t.ownerId.equals(ownerId) &
                        t.sessionId.equals(attempt.sessionId) &
                        t.questionId.equals(attempt.questionId) &
                        t.isFirstIndependent.equals(true),
                  ))
                  .getSingleOrNull();
          if (duplicateIndependent != null) {
            throw StateError(
              'Đã ghi nhận lần làm độc lập đầu tiên cho câu hỏi này.',
            );
          }
        }

        await database
            .into(database.localPracticeAttempts)
            .insert(
              LocalPracticeAttemptsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                attemptId: attempt.attemptId,
                questionId: attempt.questionId,
                grammarId: attempt.grammarId,
                contentVersion: attempt.contentVersion,
                sessionId: attempt.sessionId,
                retryOf: Value(attempt.retryOf),
                answerText: Value(attempt.answerText),
                selectedOptionIndex: Value(attempt.selectedOptionIndex),
                isCorrect: attempt.isCorrect,
                isSkipped: Value(attempt.isSkipped),
                isFirstIndependent: attempt.isFirstIndependent,
                attemptedAt: attempt.attemptedAt.toUtc(),
                serverReceivedAt: Value(attempt.serverReceivedAt?.toUtc()),
              ),
            );

        if (attempt.isFirstIndependent && !attempt.isSkipped) {
          final rows =
              await (database.select(database.localPracticeAttempts)..where(
                    (t) =>
                        t.namespace.equals(namespace) &
                        t.ownerId.equals(ownerId) &
                        t.grammarId.equals(attempt.grammarId),
                  ))
                  .get();
          final allForGrammar = rows.map(_mapAttempt).toList(growable: false);
          final now = DateTime.now().toUtc();
          final computed = computeDeterministicReviewState(
            grammarId: attempt.grammarId,
            attempts: allForGrammar,
            nowUtc: now,
            isTentative: queueRemote && attempt.serverReceivedAt == null,
          );
          await database
              .into(database.localReviewStates)
              .insertOnConflictUpdate(
                LocalReviewStatesCompanion.insert(
                  namespace: namespace,
                  ownerId: ownerId,
                  grammarId: attempt.grammarId,
                  stage: Value(computed.stage),
                  dueAt: Value(computed.dueAt),
                  algorithmVersion: Value(computed.algorithmVersion),
                  lastAttemptId: Value(computed.lastAttemptId),
                  isTentative: Value(computed.isTentative),
                  updatedAt: computed.updatedAt,
                ),
              );
        }

        if (queueRemote) {
          final now = DateTime.now().toUtc();
          await database
              .into(database.syncOutbox)
              .insert(
                SyncOutboxCompanion.insert(
                  namespace: namespace,
                  ownerId: ownerId,
                  recordId: attempt.attemptId,
                  entityTable: const Value('practice_attempts'),
                  operationId: Value(attempt.attemptId),
                  operationType: const Value('insert'),
                  createdAt: Value(now),
                  payload: jsonEncode({
                    'id': attempt.attemptId,
                    'user_id': ownerId,
                    'question_id': attempt.questionId,
                    'grammar_id': attempt.grammarId,
                    'content_version': attempt.contentVersion,
                    'session_id': attempt.sessionId,
                    'retry_of': attempt.retryOf,
                    'answer_text': attempt.answerText,
                    'selected_option_index': attempt.selectedOptionIndex,
                    'is_correct': attempt.isCorrect,
                    'is_skipped': attempt.isSkipped,
                    'is_first_independent': attempt.isFirstIndependent,
                    'attempted_at': attempt.attemptedAt
                        .toUtc()
                        .toIso8601String(),
                  }),
                ),
              );
        }
      });

  @override
  Stream<List<PracticeAttemptEntry>> watchAttempts({String? grammarId}) =>
      (database.select(database.localPracticeAttempts)
            ..where(
              (t) =>
                  t.namespace.equals(namespace) &
                  t.ownerId.equals(ownerId) &
                  (grammarId == null
                      ? const Constant(true)
                      : t.grammarId.equals(grammarId)),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.serverReceivedAt),
              (t) => OrderingTerm.asc(t.attemptedAt),
              (t) => OrderingTerm.asc(t.attemptId),
            ]))
          .watch()
          .map((rows) {
            final mapped = rows.map(_mapAttempt).toList()
              ..sort(compareCanonicalAttempt);
            return List.unmodifiable(mapped);
          });

  @override
  Stream<List<ReviewStateEntry>> watchReviewStates() =>
      (database.select(database.localReviewStates)
            ..where(
              (t) => t.namespace.equals(namespace) & t.ownerId.equals(ownerId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.grammarId)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => ReviewStateEntry(
                    grammarId: row.grammarId,
                    stage: row.stage,
                    dueAt: row.dueAt?.toUtc(),
                    algorithmVersion: row.algorithmVersion,
                    lastAttemptId: row.lastAttemptId,
                    isTentative: row.isTentative,
                    updatedAt: row.updatedAt.toUtc(),
                  ),
                )
                .toList(growable: false),
          );

  @override
  Future<void> applyCanonicalReviewStates(List<ReviewStateEntry> states) =>
      database.transaction(() async {
        final pendingAttempts =
            await (database.select(database.syncOutbox)..where(
                  (r) =>
                      r.namespace.equals(namespace) &
                      r.ownerId.equals(ownerId) &
                      r.entityTable.equals('practice_attempts'),
                ))
                .get();
        final protectedGrammarIds = <String>{};
        for (final op in pendingAttempts) {
          try {
            final decoded = jsonDecode(op.payload) as Map<String, dynamic>;
            final gId = decoded['grammar_id'];
            if (gId is String) protectedGrammarIds.add(gId);
          } catch (_) {}
        }
        for (final state in states) {
          if (protectedGrammarIds.contains(state.grammarId)) continue;
          await database
              .into(database.localReviewStates)
              .insertOnConflictUpdate(
                LocalReviewStatesCompanion.insert(
                  namespace: namespace,
                  ownerId: ownerId,
                  grammarId: state.grammarId,
                  stage: Value(state.stage),
                  dueAt: Value(state.dueAt?.toUtc()),
                  algorithmVersion: Value(state.algorithmVersion),
                  lastAttemptId: Value(state.lastAttemptId),
                  isTentative: const Value(false),
                  updatedAt: state.updatedAt.toUtc(),
                ),
              );
        }
      });

  PracticeAttemptEntry _mapAttempt(LocalPracticeAttempt row) =>
      PracticeAttemptEntry(
        attemptId: row.attemptId,
        questionId: row.questionId,
        grammarId: row.grammarId,
        contentVersion: row.contentVersion,
        sessionId: row.sessionId,
        retryOf: row.retryOf,
        answerText: row.answerText,
        selectedOptionIndex: row.selectedOptionIndex,
        isCorrect: row.isCorrect,
        isSkipped: row.isSkipped,
        isFirstIndependent: row.isFirstIndependent,
        attemptedAt: row.attemptedAt.toUtc(),
        serverReceivedAt: row.serverReceivedAt?.toUtc(),
      );
}
