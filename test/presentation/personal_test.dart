import 'dart:async';
import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/learning/domain/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'app_test.dart' show WidgetGrammar, WidgetLearning;

class PersonalFake extends WidgetLearning {
  UserProfile profile = const UserProfile();
  LearningSummary summary = const LearningSummary({}, {});
  bool failStatus = false;
  final profileChanges = StreamController<UserProfile>.broadcast();
  final summaryChanges = StreamController<LearningSummary>.broadcast();
  @override
  Stream<UserProfile> watchProfile() async* {
    yield profile;
    yield* profileChanges.stream;
  }

  @override
  Stream<LearningSummary> watchSummary() async* {
    yield summary;
    yield* summaryChanges.stream;
  }

  @override
  Future<void> saveProfile(UserProfile p) async {
    profile = p;
    profileChanges.add(p);
  }

  @override
  Future<void> setSaved(String id, bool saved) async {
    final ids = Set<String>.of(summary.saved);
    saved ? ids.add(id) : ids.remove(id);
    summary = LearningSummary(ids, summary.statuses);
    summaryChanges.add(summary);
  }

  @override
  Future<void> setStatus(String id, LearningStatus status) async {
    if (failStatus) throw StateError('storage unavailable');
    summary = LearningSummary(summary.saved, {...summary.statuses, id: status});
    summaryChanges.add(summary);
  }
}

void main() {
  testWidgets('profile validates and saved/status UI uses domain commands', (
    tester,
  ) async {
    final repository = PersonalFake();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningRepositoryProvider.overrideWithValue(repository),
          grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
        ],
        child: const BunlyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hồ sơ học tập'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), ' Hoàng ');
    await tester.enterText(find.byType(TextField).at(2), '0');
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hồ sơ không hợp lệ'), findsOneWidget);
    expect(repository.profile.displayName, isEmpty);
    await tester.enterText(find.byType(TextField).at(2), '30');
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    expect(repository.profile.displayName, 'Hoàng');
    expect(repository.profile.dailyMinutes, 30);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('N4 · 〜たことがある'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu mẫu'));
    await tester.pumpAndSettle();
    expect(repository.summary.saved, {'g'});
    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) => widget is DropdownButtonFormField<LearningStatus>,
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã nắm').last);
    await tester.pumpAndSettle();
    expect(repository.summary.statusOf('g'), LearningStatus.mastered);
    await tester.tap(find.text('Bỏ lưu mẫu'));
    await tester.pumpAndSettle();
    expect(repository.summary.saved, isEmpty);
    repository.failStatus = true;
    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) => widget is DropdownButtonFormField<LearningStatus>,
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cần ôn').last);
    await tester.pumpAndSettle();
    expect(repository.summary.statusOf('g'), LearningStatus.mastered);
    expect(find.text('Chưa lưu được thay đổi. Hãy thử lại.'), findsOneWidget);
    expect(find.text('Đã nắm'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repository.changes.close();
    await repository.profileChanges.close();
    await repository.summaryChanges.close();
  });
}
