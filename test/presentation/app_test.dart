import 'dart:async';
import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/learning/domain/learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class SessionAuth implements AuthRepository {
  final controller = StreamController<AppUser?>.broadcast();
  AppUser? user = const AppUser('A', 'a@example.test');
  @override
  AppUser? get currentUser => user;
  @override
  Stream<AppUser?> get changes => controller.stream;
  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<bool> signUp(String email, String password) async => false;
  @override
  Future<void> signOut() async {
    user = null;
    controller.add(null);
  }
}

class WidgetGrammar implements GrammarRepository {
  @override
  Future<List<GrammarPoint>> load() async => [
    const GrammarPoint(
      id: 'g',
      pattern: '〜たことがある',
      level: 'N4',
      category: 'experience',
      meaning: 'Đã từng',
      formula: 'た + ことがある',
      usage: 'Trải nghiệm',
      examples: [],
    ),
    const GrammarPoint(
      id: 'h',
      pattern: '〜たい',
      level: 'N5',
      category: 'desire',
      meaning: 'Muốn',
      formula: 'x',
      usage: 'x',
      examples: [],
    ),
  ];
}

class WidgetLearning implements LearningRepository {
  final changes = StreamController<List<Note>>.broadcast();
  final notes = <Note>[];
  @override
  Future<void> saveNote(Note note) async {
    notes.add(note);
    changes.add(List.of(notes));
  }

  @override
  Stream<List<Note>> watchNotes(String grammarId) async* {
    yield notes.where((n) => n.grammarId == grammarId).toList();
    yield* changes.stream.map(
      (items) => items.where((n) => n.grammarId == grammarId).toList(),
    );
  }
}

void main() {
  testWidgets(
    'demo filters, opens detail, saves note and shows it after returning',
    (tester) async {
      final learning = WidgetLearning();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bunly · Demo'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'đã từng');
      await tester.pumpAndSettle();
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('N5 · 〜たい'), findsNothing);
      await tester.tap(find.text('N4 · 〜たことがある'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'Ghi nhớ trải nghiệm',
      );
      await tester.ensureVisible(find.text('Lưu ghi chú'));
      await tester.tap(find.text('Lưu ghi chú'));
      await tester.pumpAndSettle();
      expect(learning.notes.single.content, 'Ghi nhớ trải nghiệm');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('N4 · 〜たことがある'));
      await tester.pumpAndSettle();
      expect(find.text('Ghi nhớ trải nghiệm'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await learning.changes.close();
    },
  );
  testWidgets('changing account removes private detail routes', (tester) async {
    final learning = WidgetLearning();
    final auth = SessionAuth();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
          learningRepositoryProvider.overrideWithValue(learning),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: const BunlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('N4 · 〜たことがある'));
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú của bạn'), findsOneWidget);
    auth.user = const AppUser('B', 'b@example.test');
    auth.controller.add(auth.user);
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú của bạn'), findsNothing);
    expect(find.text('Kho ngữ pháp'), findsOneWidget);
    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await auth.controller.close();
    await learning.changes.close();
  });
}
