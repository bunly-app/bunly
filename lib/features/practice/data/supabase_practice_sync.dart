import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../domain/practice_storage.dart';
import 'local_practice_storage_repository.dart';

abstract interface class PracticeRemote {
  bool ownsSession(String ownerId);
  Future<List<Map<String, dynamic>>> fetchQuestions();
  Future<void> insertAttemptIdempotent(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> fetchAttempts(String ownerId);
  Future<List<Map<String, dynamic>>> fetchReviewStates(String ownerId);
}

class SupabasePracticeRemote implements PracticeRemote {
  SupabasePracticeRemote(
    this.authClient, {
    required String url,
    required String key,
    required String ownerId,
  }) : client = SupabaseClient(
         url,
         key,
         accessToken: () async {
           final session = authClient.auth.currentSession;
           if (session == null || session.user.id != ownerId) {
             throw StateError('Session owner changed');
           }
           return session.accessToken;
         },
       );

  final SupabaseClient authClient;
  final SupabaseClient client;

  Future<void> dispose() => client.dispose();

  @override
  bool ownsSession(String ownerId) =>
      authClient.auth.currentSession != null &&
      authClient.auth.currentUser?.id == ownerId;

  @override
  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final result = <Map<String, dynamic>>[];
    for (var start = 0; ; start += 500) {
      final rows = await client
          .from('practice_questions')
          .select()
          .order('id')
          .range(start, start + 499);
      result.addAll(rows);
      if (rows.length < 500) return result;
    }
  }

  @override
  Future<void> insertAttemptIdempotent(Map<String, dynamic> payload) async {
    await client
        .from('practice_attempts')
        .upsert(payload, onConflict: 'id', ignoreDuplicates: true);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttempts(String ownerId) async {
    final result = <Map<String, dynamic>>[];
    for (var start = 0; ; start += 500) {
      final rows = await client
          .from('practice_attempts')
          .select()
          .eq('user_id', ownerId)
          .order('server_received_at')
          .order('id')
          .range(start, start + 499);
      result.addAll(rows);
      if (rows.length < 500) return result;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReviewStates(String ownerId) async {
    final result = <Map<String, dynamic>>[];
    for (var start = 0; ; start += 500) {
      final rows = await client
          .from('review_states')
          .select()
          .eq('user_id', ownerId)
          .order('grammar_id')
          .range(start, start + 499);
      result.addAll(rows);
      if (rows.length < 500) return result;
    }
  }
}

class PracticeSync {
  PracticeSync(
    this.database,
    this.remote,
    this.storage, {
    required this.namespace,
    required this.ownerId,
  });

  final AppDatabase database;
  final PracticeRemote remote;
  final LocalPracticeStorageRepository storage;
  final String namespace;
  final String ownerId;

  bool _active = true;
  Future<void>? _running;

  void stop() => _active = false;
  bool get _valid => _active && remote.ownsSession(ownerId);

  void _requireSession() {
    if (!_valid) {
      throw StateError(
        'Phiên đăng nhập đã thay đổi. Bài làm chờ đồng bộ vẫn được giữ trên máy.',
      );
    }
  }

  Future<void> run() {
    if (_running != null) return _running!;
    return _running = _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    _requireSession();
    final operations =
        await (database.select(database.syncOutbox)
              ..where(
                (r) =>
                    r.namespace.equals(namespace) &
                    r.ownerId.equals(ownerId) &
                    r.entityTable.equals('practice_attempts'),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.sequence)]))
            .get();

    for (final op in operations) {
      _requireSession();
      final payload = jsonDecode(op.payload) as Map<String, dynamic>;
      if (payload['user_id'] != ownerId) {
        throw StateError('Thao tác đồng bộ không hợp lệ.');
      }
      await remote.insertAttemptIdempotent(payload);
      _requireSession();
      await (database.delete(database.syncOutbox)..where(
            (r) =>
                r.sequence.equals(op.sequence) &
                r.ownerId.equals(ownerId) &
                r.namespace.equals(namespace),
          ))
          .go();
    }

    _requireSession();
    final questionRows = await remote.fetchQuestions();
    _requireSession();
    await storage.replaceCachedQuestions(
      questionRows.map(practiceQuestionFromJson).toList(growable: false),
    );

    _requireSession();
    final remoteAttempts = await remote.fetchAttempts(ownerId);
    _requireSession();
    await database.transaction(() async {
      _requireSession();
      for (final row in remoteAttempts) {
        if (row['user_id'] != ownerId) {
          throw StateError('Sai chủ sở hữu dữ liệu.');
        }
        await database
            .into(database.localPracticeAttempts)
            .insertOnConflictUpdate(
              LocalPracticeAttemptsCompanion.insert(
                namespace: namespace,
                ownerId: ownerId,
                attemptId: row['id'] as String,
                questionId: row['question_id'] as String,
                grammarId: row['grammar_id'] as String,
                contentVersion: (row['content_version'] as num).toInt(),
                sessionId: row['session_id'] as String,
                retryOf: Value(row['retry_of'] as String?),
                answerText: Value(row['answer_text'] as String? ?? ''),
                selectedOptionIndex: Value(
                  (row['selected_option_index'] as num?)?.toInt(),
                ),
                isCorrect: row['is_correct'] as bool,
                isSkipped: Value(row['is_skipped'] as bool? ?? false),
                isFirstIndependent: row['is_first_independent'] as bool,
                attemptedAt: DateTime.parse(row['attempted_at'] as String),
                serverReceivedAt: Value(
                  row['server_received_at'] == null
                      ? null
                      : DateTime.parse(row['server_received_at'] as String),
                ),
              ),
            );
      }
    });

    _requireSession();
    final remoteReviews = await remote.fetchReviewStates(ownerId);
    _requireSession();
    await storage.applyCanonicalReviewStates(
      remoteReviews
          .map((row) {
            if (row['user_id'] != ownerId) {
              throw StateError('Sai chủ sở hữu dữ liệu.');
            }
            return ReviewStateEntry(
              grammarId: row['grammar_id'] as String,
              stage: (row['stage'] as num).toInt(),
              dueAt: row['due_at'] == null
                  ? null
                  : DateTime.parse(row['due_at'] as String).toUtc(),
              algorithmVersion:
                  (row['algorithm_version'] as num?)?.toInt() ?? 1,
              lastAttemptId: row['last_attempt_id'] as String?,
              isTentative: false,
              updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
            );
          })
          .toList(growable: false),
    );
  }
}
