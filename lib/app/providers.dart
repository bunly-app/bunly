import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' show BooleanExpressionOperators;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/database/app_database.dart';
import '../features/analysis/data/catalog_sentence_preview.dart';
import '../features/analysis/data/supabase_grammar_analysis_repository.dart';
import '../features/analysis/domain/grammar_analysis.dart';
import '../features/analysis/domain/sentence_preview.dart';
import '../features/auth/data/auth_repositories.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/authenticate.dart';
import '../features/auth/domain/request_password_reset.dart';
import '../features/auth/domain/resend_confirmation.dart';
import '../features/auth/domain/sign_out.dart';
import '../features/auth/domain/update_password.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/email_verification_controller.dart';
import '../features/auth/presentation/password_reset_controller.dart';
import '../features/auth/presentation/sign_out_controller.dart';
import '../features/auth/presentation/update_password_controller.dart';
import '../features/grammar/data/cached_grammar_repository.dart';
import '../features/grammar/data/grammar_sources.dart';
import '../features/grammar/domain/grammar_catalog.dart';
import '../features/grammar/domain/grammar_point.dart';
import '../features/grammar/domain/grammar_repository.dart';
import '../features/grammar/domain/search_grammar.dart';
import '../features/learning/data/learning_sync.dart';
import '../features/learning/data/local_learning_repository.dart';
import '../features/learning/domain/learning_overview.dart';
import '../features/learning/domain/learning_repository.dart';
import '../features/learning/domain/note.dart';
import '../features/learning/domain/personal_repository.dart';
import '../features/learning/domain/save_note.dart';
import '../features/learning/domain/watch_notebook_notes.dart';
import '../features/learning/presentation/learning_controller.dart';
import '../features/learning/presentation/note_controller.dart';
import '../features/ocr/data/mlkit_ocr_repository.dart';
import '../features/ocr/domain/ocr_draft.dart';
import '../features/practice/data/local_practice_storage_repository.dart';
import '../features/practice/data/stitch_demo_practice.dart';
import '../features/practice/data/supabase_practice_sync.dart';
import '../features/practice/domain/demo_practice.dart';
import '../features/practice/domain/practice_storage.dart';
import '../features/settings/domain/app_settings_repository.dart';
import '../features/settings/presentation/theme_controller.dart';
import 'config.dart';

final startDemoPracticeProvider = Provider<StartDemoPractice>(
  (ref) => const StartDemoPractice(StitchDemoPractice()),
);

final onDeviceGrammarDetectorProvider = Provider<OnDeviceGrammarDetector>(
  (ref) => const OnDeviceGrammarDetector(),
);

final previewSentenceProvider = Provider<PreviewSentence>(
  (ref) => PreviewSentence(
    OnDeviceSentencePreview(
      ref.watch(grammarRepositoryProvider),
      detector: ref.watch(onDeviceGrammarDetectorProvider),
    ),
  ),
);

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final repo = MlKitOcrRepository();
  ref.onDispose(() => unawaited(repo.dispose()));
  return repo;
});

final scanJapaneseTextProvider = Provider<ScanJapaneseText>(
  (ref) => ScanJapaneseText(ref.watch(ocrRepositoryProvider)),
);

final grammarAnalysisRepositoryProvider = Provider<GrammarAnalysisRepository?>((
  ref,
) {
  final config = ref.watch(configProvider);
  final user = ref.watch(userProvider).valueOrNull;
  if (!config.connected || user == null) return null;
  return SupabaseGrammarAnalysisRepository(Supabase.instance.client);
});

final analyzeGrammarSentenceProvider = Provider<AnalyzeGrammarSentence?>((ref) {
  final repo = ref.watch(grammarAnalysisRepositoryProvider);
  if (repo == null) return null;
  return AnalyzeGrammarSentence(repo, ref.watch(grammarRepositoryProvider));
});

final analysisQuotaProvider = FutureProvider.autoDispose<AnalysisQuotaStatus?>((
  ref,
) async {
  ref.watch(userProvider.select((session) => session.valueOrNull?.id));
  final repo = ref.watch(grammarAnalysisRepositoryProvider);
  if (repo == null) return null;
  return GetAnalysisQuota(repo)();
});

final configProvider = Provider<AppConfig>((ref) => const AppConfig());
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository?>(
  (ref) => null,
);

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemePreference>(
      (ref) => ThemeController(ref.watch(appSettingsRepositoryProvider)),
    );

final themeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(themeControllerProvider)) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(configProvider).connected) {
    final repo = SupabaseAuthRepository(Supabase.instance.client);
    ref.onDispose(repo.dispose);
    return repo;
  }
  return DemoAuthRepository();
});

final userProvider = StreamProvider<AppUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentUser;
  yield* repository.changes;
});

final passwordRecoveryProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).recoveryEvents;
});

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<String?>>(
      (ref) => AuthController(Authenticate(ref.watch(authRepositoryProvider))),
    );

final emailVerificationControllerProvider =
    StateNotifierProvider.autoDispose<
      EmailVerificationController,
      AsyncValue<String?>
    >(
      (ref) => EmailVerificationController(
        ResendConfirmation(ref.watch(authRepositoryProvider)),
      ),
    );

final passwordResetControllerProvider =
    StateNotifierProvider.autoDispose<
      PasswordResetController,
      AsyncValue<bool>
    >(
      (ref) => PasswordResetController(
        RequestPasswordReset(ref.watch(authRepositoryProvider)),
      ),
    );

final updatePasswordControllerProvider =
    StateNotifierProvider.autoDispose<
      UpdatePasswordController,
      AsyncValue<bool>
    >((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return UpdatePasswordController(UpdatePassword(repo), repo);
    });

final signOutControllerProvider =
    StateNotifierProvider.autoDispose<SignOutController, AsyncValue<void>>(
      (ref) => SignOutController(SignOut(ref.watch(authRepositoryProvider))),
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
final catalogProvider = FutureProvider.autoDispose<GrammarCatalog>(
  (ref) => SearchGrammar(ref.watch(grammarRepositoryProvider))(),
);

typedef GrammarFilter = ({String query, String? level, String? category});
final grammarFilterProvider = StateProvider.autoDispose<GrammarFilter>((ref) {
  ref.watch(userProvider.select((session) => session.valueOrNull?.id));
  return (query: '', level: null, category: null);
});
final filteredGrammarProvider =
    Provider.autoDispose<AsyncValue<List<GrammarPoint>>>((ref) {
      final filter = ref.watch(grammarFilterProvider);
      return ref
          .watch(catalogProvider)
          .whenData(
            (catalog) => filterGrammar(
              catalog.points,
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
final notebookNotesProvider = StreamProvider.autoDispose<List<Note>>(
  (ref) => WatchNotebookNotes(ref.watch(learningRepositoryProvider))(),
);
final noteConflictsProvider = StreamProvider.autoDispose<List<NoteConflict>>((
  ref,
) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  final repo = ref.watch(learningRepositoryProvider);
  if (repo is LocalLearningRepository) {
    return repo.watchNoteConflicts();
  }
  return Stream.value(const []);
});
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
final learningOverviewProvider =
    Provider.autoDispose<AsyncValue<LearningOverview>>((ref) {
      final catalog = ref.watch(catalogProvider);
      final summary = ref.watch(learningSummaryProvider);
      if (catalog.hasError) {
        return AsyncError(catalog.error!, catalog.stackTrace!);
      }
      if (summary.hasError) {
        return AsyncError(summary.error!, summary.stackTrace!);
      }
      if (catalog.isLoading ||
          summary.isLoading ||
          !catalog.hasValue ||
          !summary.hasValue) {
        return const AsyncLoading();
      }
      return AsyncData(
        const BuildLearningOverview()(
          catalog.requireValue.points,
          summary.requireValue,
        ),
      );
    });
final learningControllerProvider =
    StateNotifierProvider.autoDispose<LearningController, AsyncValue<void>>(
      (ref) => LearningController(
        UpdateLearning(ref.watch(personalRepositoryProvider)),
      ),
    );

final practiceStorageRepositoryProvider =
    Provider.autoDispose<PracticeStorageRepository>((ref) {
      final user = ref.watch(userProvider).valueOrNull;
      if (user == null) throw StateError('A session is required');
      final config = ref.watch(configProvider);
      return LocalPracticeStorageRepository(
        ref.watch(databaseProvider),
        namespace: config.namespace,
        ownerId: user.id,
        queueRemote: config.connected,
      );
    });

final cachedQuestionsProvider =
    FutureProvider.autoDispose<List<CuratedPracticeQuestion>>((ref) async {
      final user = ref.watch(userProvider).valueOrNull;
      if (user == null) return const [];
      final config = ref.watch(configProvider);
      final storage = ref.watch(practiceStorageRepositoryProvider);
      final existing = await storage.loadCachedQuestions();
      if (existing.isNotEmpty ||
          config.connected ||
          storage is! LocalPracticeStorageRepository) {
        return existing;
      }
      final raw = await rootBundle.loadString(
        'assets/data/practice_questions.json',
      );
      final decoded = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(practiceQuestionFromJson)
          .toList(growable: false);
      if (decoded.isEmpty) return existing;
      await storage.replaceCachedQuestions(decoded);
      return storage.loadCachedQuestions();
    });

final practiceAttemptsProvider =
    StreamProvider.autoDispose<List<PracticeAttemptEntry>>((ref) {
      final user = ref.watch(userProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return ref.watch(practiceStorageRepositoryProvider).watchAttempts();
    });

final reviewStatesProvider = StreamProvider.autoDispose<List<ReviewStateEntry>>(
  (ref) {
    final user = ref.watch(userProvider).valueOrNull;
    if (user == null) return Stream.value(const []);
    return ref.watch(practiceStorageRepositoryProvider).watchReviewStates();
  },
);

final dueReviewStatesProvider =
    StreamProvider.autoDispose<List<ReviewStateEntry>>((ref) {
      final user = ref.watch(userProvider).valueOrNull;
      if (user == null) return Stream.value(const []);
      return WatchDueReviewStates(ref.watch(practiceStorageRepositoryProvider))(
        () => DateTime.now().toUtc(),
      );
    });

final practiceSyncProvider = Provider.autoDispose<PracticeSync?>((ref) {
  final config = ref.watch(configProvider);
  final user = ref.watch(userProvider).valueOrNull;
  if (!config.connected || user == null) return null;
  final storage = ref.watch(practiceStorageRepositoryProvider);
  if (storage is! LocalPracticeStorageRepository) return null;
  final remote = SupabasePracticeRemote(
    Supabase.instance.client,
    url: config.supabaseUrl,
    key: config.supabaseAnonKey,
    ownerId: user.id,
  );
  ref.onDispose(() => unawaited(remote.dispose()));
  final sync = PracticeSync(
    ref.watch(databaseProvider),
    remote,
    storage,
    namespace: config.namespace,
    ownerId: user.id,
  );
  ref.onDispose(sync.stop);
  return sync;
});

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
        (r) =>
            r.namespace.equals(config.namespace) &
            r.ownerId.equals(user.id) &
            r.conflictPayload.isNull(),
      ))
      .watch()
      .map((rows) => rows.length);
});
