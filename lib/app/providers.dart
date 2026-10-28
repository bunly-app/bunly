import 'dart:async';
import 'package:drift/drift.dart' show BooleanExpressionOperators;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/database/app_database.dart';
import '../features/auth/data/auth_repositories.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/authenticate.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/grammar/data/cached_grammar_repository.dart';
import '../features/grammar/data/grammar_sources.dart';
import '../features/grammar/domain/grammar_point.dart';
import '../features/grammar/domain/grammar_repository.dart';
import '../features/grammar/domain/search_grammar.dart';
import '../features/learning/data/local_learning_repository.dart';
import '../features/learning/domain/learning_repository.dart';
import '../features/learning/domain/note.dart';
import '../features/learning/domain/save_note.dart';
import '../features/learning/presentation/note_controller.dart';
import '../features/learning/domain/personal_repository.dart';
import '../features/learning/data/learning_sync.dart';
import '../features/learning/presentation/learning_controller.dart';
import 'config.dart';

final configProvider = Provider<AppConfig>((ref) => const AppConfig());
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(configProvider).connected
      ? SupabaseAuthRepository(Supabase.instance.client)
      : DemoAuthRepository(),
);

final userProvider = StreamProvider<AppUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentUser;
  yield* repository.changes;
});

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<String?>>(
      (ref) => AuthController(Authenticate(ref.watch(authRepositoryProvider))),
    );

final grammarRepositoryProvider = Provider.autoDispose<GrammarRepository>((
  ref,
) {
  // Recreate on account/session changes so no old request can populate a new UI.
  ref.watch(userProvider);
  final config = ref.watch(configProvider);
  return CachedGrammarRepository(
    ref.watch(databaseProvider),
    config.connected
        ? SupabaseGrammarSource(Supabase.instance.client)
        : AssetGrammarSource(),
    config.namespace,
  );
});
final catalogProvider = FutureProvider.autoDispose<List<GrammarPoint>>(
  (ref) => SearchGrammar(ref.watch(grammarRepositoryProvider))(),
);

typedef GrammarFilter = ({String query, String? level, String? category});
final grammarFilterProvider = StateProvider.autoDispose<GrammarFilter>(
  (ref) => (query: '', level: null, category: null),
);
final filteredGrammarProvider =
    Provider.autoDispose<AsyncValue<List<GrammarPoint>>>((ref) {
      final filter = ref.watch(grammarFilterProvider);
      return ref
          .watch(catalogProvider)
          .whenData(
            (points) => filterGrammar(
              points,
              query: filter.query,
              level: filter.level,
              category: filter.category,
            ),
          );
    });

final learningRepositoryProvider = Provider.autoDispose<LearningRepository>((
  ref,
) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) throw StateError('A session is required');
  final config = ref.watch(configProvider);
  return LocalLearningRepository(
    ref.watch(databaseProvider),
    namespace: config.namespace,
    ownerId: user.id,
    queueRemote: config.connected,
  );
});
final notesProvider = StreamProvider.autoDispose.family<List<Note>, String>(
  (ref, grammarId) =>
      ref.watch(learningRepositoryProvider).watchNotes(grammarId),
);
final noteControllerProvider =
    StateNotifierProvider.autoDispose<NoteController, AsyncValue<void>>(
      (ref) => NoteController(SaveNote(ref.watch(learningRepositoryProvider))),
    );

final personalRepositoryProvider = Provider.autoDispose<PersonalRepository>(
  (ref) => ref.watch(learningRepositoryProvider) as PersonalRepository,
);
final profileProvider = StreamProvider.autoDispose<UserProfile>(
  (ref) => ref.watch(personalRepositoryProvider).watchProfile(),
);
final learningSummaryProvider = StreamProvider.autoDispose<LearningSummary>(
  (ref) => ref.watch(personalRepositoryProvider).watchSummary(),
);
final learningControllerProvider =
    StateNotifierProvider.autoDispose<LearningController, AsyncValue<void>>(
      (ref) => LearningController(
        UpdateLearning(ref.watch(personalRepositoryProvider)),
      ),
    );

final learningSyncProvider = Provider.autoDispose<LearningSync?>((ref) {
  final config = ref.watch(configProvider);
  final user = ref.watch(userProvider).valueOrNull;
  if (!config.connected || user == null) return null;
  final remote = SupabaseLearningRemote(
    Supabase.instance.client,
    url: config.supabaseUrl,
    key: config.supabaseAnonKey,
    ownerId: user.id,
  );
  ref.onDispose(() => unawaited(remote.dispose()));
  final sync = LearningSync(
    ref.watch(databaseProvider),
    remote,
    namespace: config.namespace,
    ownerId: user.id,
  );
  ref.onDispose(sync.stop);
  return sync;
});
final pendingSyncProvider = StreamProvider.autoDispose<int>((ref) {
  final config = ref.watch(configProvider);
  final user = ref.watch(userProvider).valueOrNull;
  if (!config.connected || user == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncOutbox)..where(
        (r) => r.namespace.equals(config.namespace) & r.ownerId.equals(user.id),
      ))
      .watch()
      .map((rows) => rows.length);
});
