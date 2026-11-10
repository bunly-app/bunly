import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bunly/app/config.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/auth/data/auth_repositories.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/grammar/data/cached_grammar_repository.dart';
import 'package:bunly/features/grammar/data/grammar_mapper.dart';
import 'package:bunly/features/grammar/data/grammar_sources.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/presentation/grammar_screen.dart';
import 'package:bunly/features/learning/data/learning_sync.dart';
import 'package:bunly/features/learning/presentation/sync_banner.dart';
import 'package:bunly/features/practice/data/local_practice_storage_repository.dart';
import 'package:bunly/features/practice/domain/practice_engine.dart';
import 'package:bunly/features/practice/domain/practice_storage.dart';
import 'package:bunly/features/practice/presentation/practice_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeLearningSync implements LearningSync {
  bool offline = false;
  int runCalls = 0;

  @override
  AppDatabase get database => throw UnimplementedError();

  @override
  LearningRemote get remote => throw UnimplementedError();

  @override
  String get namespace => 'connected';

  @override
  String get ownerId => 'u1';

  @override
  void stop() {}

  @override
  Future<void> run() async {
    runCalls++;
    if (offline) throw const SocketException('offline');
  }
}

Future<List<GrammarPoint>> _loadBundledGrammar() async {
  final raw = await rootBundle.loadString('assets/data/grammar.json');
  return (jsonDecode(raw) as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(grammarFromJson)
      .toList(growable: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled N5/N4 curriculum seeds 90 grammar points and 180 curated questions offline',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final catalog = await CachedGrammarRepository(
        db,
        AssetGrammarSource(),
        'demo',
      ).load();
      final grammar = catalog.points;
      expect(grammar.length, 90);
      expect(grammar.where((g) => g.level == 'N5').length, 45);
      expect(grammar.where((g) => g.level == 'N4').length, 45);

      final storage = LocalPracticeStorageRepository(
        db,
        namespace: 'demo',
        ownerId: 'demo-user',
        queueRemote: false,
      );
      final container = ProviderContainer(
        overrides: [
          configProvider.overrideWithValue(const AppConfig(connected: false)),
          databaseProvider.overrideWithValue(db),
          userProvider.overrideWith(
            (ref) => Stream.value(const AppUser('demo-user', '')),
          ),
          practiceStorageRepositoryProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final userSub = container.listen(userProvider, (_, _) {});
      addTearDown(userSub.close);
      await container.read(userProvider.future);

      final questionsSub = container.listen(cachedQuestionsProvider, (_, _) {});
      addTearDown(questionsSub.close);

      final questions = await container.read(cachedQuestionsProvider.future);
      expect(questions.length, 180);
      expect(questions.where((q) => q.type == PracticeBankType.mcq).length, 90);
      expect(
        questions.where((q) => q.type == PracticeBankType.cloze).length,
        90,
      );

      final grammarIds = grammar.map((g) => g.id).toSet();
      for (final q in questions) {
        expect(
          grammarIds.contains(q.grammarId),
          isTrue,
          reason: 'Question ${q.id} references unknown grammar ${q.grammarId}',
        );
        if (q.type == PracticeBankType.cloze) {
          final bank = buildClozeWordBank(q, questions);
          expect(bank, contains(q.acceptedAnswers.first));
          expect(
            bank.any((chip) => chip.contains('Tôi đã')),
            isFalse,
            reason: 'Cloze bank for ${q.id} must prefer Japanese tokens',
          );
        }
      }
    },
  );

  testWidgets('GrammarScreen maps every category present in grammar.json', (
    tester,
  ) async {
    final grammar = (await tester.runAsync(_loadBundledGrammar))!;
    final categories = grammar.map((g) => g.category).toSet();
    expect(categories.length, greaterThanOrEqualTo(15));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogProvider.overrideWith(
            (ref) async =>
                GrammarCatalog(grammar, origin: GrammarOrigin.source),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: GrammarScreen())),
      ),
    );
    await tester.pumpAndSettle();

    for (final rawSlug in categories) {
      if (rawSlug.contains('_')) {
        expect(find.widgetWithText(FilterChip, rawSlug), findsNothing);
      }
    }
    expect(find.widgetWithText(FilterChip, 'Trợ từ'), findsOneWidget);
    expect(
      find.widgetWithText(FilterChip, 'Nguyên nhân & Tương phản'),
      findsOneWidget,
    );
  });

  test(
    'SupabaseAuthRepository.mapAuthStateChanges keeps cached user on offline refresh error',
    () async {
      final controller = StreamController<AuthState>();
      addTearDown(controller.close);
      const cached = User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
        email: 'hocvien@bunly.edu.vn',
      );
      User? current = cached;

      final mapped = SupabaseAuthRepository.mapAuthStateChanges(
        controller.stream,
        () => current,
      );

      final events = <String>[];
      final sub = mapped.listen(
        (u) => events.add(u == null ? 'NULL_USER' : '${u.id}:${u.email}'),
        onError: (Object e) => events.add('ERR:$e'),
      );
      addTearDown(sub.cancel);

      controller.addError(AuthRetryableFetchException(message: 'offline'));
      controller.addError(const SocketException('network unreachable'));
      await Future<void>.delayed(Duration.zero);

      expect(events, [
        'user-1:hocvien@bunly.edu.vn',
        'user-1:hocvien@bunly.edu.vn',
      ]);

      current = null;
      controller.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);
      expect(events.last, 'NULL_USER');
    },
  );

  testWidgets(
    'SyncBanner auto-syncs on outbox increase, collapses when synced, and offers retry on failure',
    (tester) async {
      final sync = _FakeLearningSync();
      final pendingController = StreamController<int>.broadcast();
      addTearDown(pendingController.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningSyncProvider.overrideWithValue(sync),
            practiceSyncProvider.overrideWithValue(null),
            pendingSyncProvider.overrideWith((ref) => pendingController.stream),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [SyncBanner()])),
          ),
        ),
      );

      // Initial postFrame sync runs once and collapses cleanly when idle.
      await tester.pumpAndSettle();
      expect(sync.runCalls, 1);
      expect(find.text('Đồng bộ'), findsNothing);
      expect(tester.getSize(find.byType(SyncBanner)), Size.zero);

      // Simulate new outbox write -> triggers debounced auto-sync automatically.
      pendingController.add(1);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(sync.runCalls, 2);

      // Simulate offline failure -> error banner appears and retries on tap.
      sync.offline = true;
      pendingController.add(2);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Chưa đồng bộ được. Chạm để thử lại.'), findsOneWidget);

      sync.offline = false;
      pendingController.add(0);
      await tester.tap(find.text('Chưa đồng bộ được. Chạm để thử lại.'));
      await tester.pumpAndSettle();
      expect(sync.runCalls, 4);
      expect(tester.getSize(find.byType(SyncBanner)), Size.zero);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'PracticeSetupScreen fits full 90-point N5/N4 bank without overflow on small & large viewports',
    (tester) async {
      final loaded = (await tester.runAsync(() async {
        final rawQuestions =
            jsonDecode(
                  await rootBundle.loadString(
                    'assets/data/practice_questions.json',
                  ),
                )
                as List<dynamic>;
        final questions = rawQuestions
            .cast<Map<String, dynamic>>()
            .map(practiceQuestionFromJson)
            .toList(growable: false);
        final grammar = await _loadBundledGrammar();
        return (grammar: grammar, questions: questions);
      }))!;

      for (final (size, scale) in [
        (const Size(320, 640), 2.0),
        (const Size(1024, 768), 1.4),
      ]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });

        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey('scope-$size-$scale'),
            overrides: [
              catalogProvider.overrideWith(
                (ref) async => GrammarCatalog(
                  loaded.grammar,
                  origin: GrammarOrigin.source,
                ),
              ),
              cachedQuestionsProvider.overrideWith(
                (ref) async => loaded.questions,
              ),
              dueReviewStatesProvider.overrideWith(
                (ref) => Stream.value(const []),
              ),
              practiceAttemptsProvider.overrideWith(
                (ref) => Stream.value(const []),
              ),
            ],
            child: const MaterialApp(home: PracticeSetupScreen()),
          ),
        );
        await tester.pumpAndSettle();

        final setupScroll = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Theo mẫu đang chọn'),
          180,
          scrollable: setupScroll,
        );
        await tester.ensureVisible(find.text('Theo mẫu đang chọn'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Theo mẫu đang chọn'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byType(DropdownButtonFormField<String>),
          150,
          scrollable: setupScroll,
        );
        await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    },
  );
}
