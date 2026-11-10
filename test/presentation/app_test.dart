import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/learning/domain/learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_practice_storage.dart';

class SessionAuth implements AuthRepository {
  final controller = StreamController<AppUser?>.broadcast();
  final recoveryController = StreamController<bool>.broadcast();
  AppUser? user = const AppUser('A', 'a@example.test');
  bool recovering = false;
  @override
  AppUser? get currentUser => user;
  @override
  Stream<AppUser?> get changes => controller.stream;
  @override
  Stream<bool> get recoveryEvents async* {
    yield recovering;
    yield* recoveryController.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {}
  @override
  Future<bool> signUp(String email, String password) async => false;
  @override
  Future<void> resendConfirmation(String email) async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> completeRecovery() async {
    recovering = false;
    if (!recoveryController.isClosed) recoveryController.add(false);
  }

  @override
  Future<void> signOut() async {
    user = null;
    recovering = false;
    controller.add(null);
    if (!recoveryController.isClosed) recoveryController.add(false);
  }
}

class WidgetGrammar implements GrammarRepository {
  @override
  Future<GrammarCatalog> load() async => GrammarCatalog([
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
  ], origin: GrammarOrigin.source);
}

class WidgetLearning implements LearningRepository, PersonalRepository {
  @override
  Stream<List<Note>> watchAllNotes() async* {
    yield List.of(notes);
    yield* changes.stream;
  }

  @override
  Stream<UserProfile> watchProfile() => Stream.value(const UserProfile());
  @override
  Future<void> saveProfile(UserProfile profile) async {}
  @override
  Stream<LearningSummary> watchSummary() =>
      Stream.value(const LearningSummary({}, {}));
  @override
  Future<void> setSaved(String id, bool saved) async {}
  @override
  Future<void> setStatus(String id, LearningStatus status) async {}
  @override
  Future<void> deleteNote(String id) async {
    notes.removeWhere((n) => n.id == id);
    changes.add(List.of(notes));
  }

  final changes = StreamController<List<Note>>.broadcast();
  final notes = <Note>[];
  @override
  Future<void> saveNote(Note note) async {
    notes.removeWhere((existing) => existing.id == note.id);
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
    'demo filters, opens detail, creates/edits/deletes notes and returns safely',
    (tester) async {
      final learning = WidgetLearning();
      final practiceStorage = FakePracticeStorageRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bunly'), findsOneWidget);
      expect(
        find.text('Chế độ ngoại tuyến · Dữ liệu và ghi chú lưu trên thiết bị.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tra cứu'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'đã từng');
      await tester.pumpAndSettle();
      expect(find.text('N4 · 〜たことがある'), findsOneWidget);
      expect(find.text('N5 · 〜たい'), findsNothing);
      await tester.tap(find.text('N4 · 〜たことがある'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        250,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.enterText(
        find.byType(TextField).last,
        'Ghi nhớ trải nghiệm',
      );
      await tester.ensureVisible(find.text('Lưu ghi chú'));
      await tester.tap(find.text('Lưu ghi chú'));
      await tester.pumpAndSettle();
      expect(learning.notes.single.content, 'Ghi nhớ trải nghiệm');
      await tester.scrollUntilVisible(
        find.byTooltip('Sửa ghi chú'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sửa ghi chú'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Ghi chú đã sửa');
      await tester.ensureVisible(find.text('Lưu chỉnh sửa'));
      await tester.tap(find.text('Lưu chỉnh sửa'));
      await tester.pumpAndSettle();
      expect(learning.notes, hasLength(1));
      expect(learning.notes.single.content, 'Ghi chú đã sửa');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('N4 · 〜たことがある'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Ghi chú đã sửa'), 250);
      expect(find.text('Ghi chú đã sửa'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Xóa ghi chú'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Xóa ghi chú'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa').last);
      await tester.pumpAndSettle();
      expect(learning.notes, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await learning.changes.close();
      await practiceStorage.dispose();
    },
  );
  testWidgets('changing account removes private detail routes', (tester) async {
    final learning = WidgetLearning();
    final practiceStorage = FakePracticeStorageRepository();
    final auth = SessionAuth();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
          learningRepositoryProvider.overrideWithValue(learning),
          practiceStorageRepositoryProvider.overrideWithValue(practiceStorage),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: const BunlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tra cứu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('N4 · 〜たことがある'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết ngữ pháp'), findsOneWidget);
    auth.user = const AppUser('B', 'b@example.test');
    auth.controller.add(auth.user);
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết ngữ pháp'), findsNothing);
    expect(find.text('Một mẫu ngữ pháp, một bước học tiếp.'), findsOneWidget);
    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await auth.controller.close();
    await learning.changes.close();
    await practiceStorage.dispose();
  });
}
