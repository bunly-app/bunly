import 'package:bunly/app/config.dart';
import 'package:bunly/core/database/app_database.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/auth/domain/authenticate.dart';
import 'package:bunly/features/auth/domain/request_password_reset.dart';
import 'package:bunly/features/auth/domain/resend_confirmation.dart';
import 'package:bunly/features/auth/domain/update_password.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_catalog.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/grammar/domain/search_grammar.dart';
import 'package:bunly/features/learning/data/local_learning_repository.dart';
import 'package:bunly/features/learning/domain/learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/save_note.dart';
import 'package:bunly/features/settings/data/local_app_settings_repository.dart';
import 'package:bunly/features/settings/domain/app_settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryLearning implements LearningRepository {
  @override
  Stream<List<Note>> watchAllNotes() => Stream.value([]);

  Note? saved;
  @override
  Future<void> saveNote(Note note) async {
    saved = note;
  }

  @override
  Stream<List<Note>> watchNotes(String grammarId) => Stream.value([]);
}

class MemoryGrammar implements GrammarRepository {
  MemoryGrammar({this.origin = GrammarOrigin.source});
  final GrammarOrigin origin;
  @override
  Future<GrammarCatalog> load() async => GrammarCatalog([
    const GrammarPoint(
      id: '1',
      pattern: '〜たい',
      level: 'N5',
      category: 'desire',
      meaning: 'Muốn làm',
      formula: 'x',
      usage: 'x',
      examples: [],
    ),
    const GrammarPoint(
      id: '2',
      pattern: '〜たことがある',
      level: 'N4',
      category: 'experience',
      meaning: 'Đã từng',
      formula: 'x',
      usage: 'x',
      examples: [],
    ),
  ], origin: origin);
}

class PendingConfirmationAuth implements AuthRepository {
  bool called = false;
  String? lastEmail;
  String? lastUpdatedPassword;
  int resendCount = 0;
  int resetCount = 0;

  @override
  AppUser? get currentUser => null;
  @override
  Stream<AppUser?> get changes => const Stream.empty();
  @override
  Stream<bool> get recoveryEvents => Stream.value(false);

  @override
  Future<void> signIn(String email, String password) async {
    called = true;
    lastEmail = email;
  }

  @override
  Future<bool> signUp(String email, String password) async {
    called = true;
    lastEmail = email;
    return false;
  }

  @override
  Future<void> resendConfirmation(String email) async {
    called = true;
    resendCount++;
    lastEmail = email;
  }

  @override
  Future<void> resetPassword(String email) async {
    called = true;
    resetCount++;
    lastEmail = email;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    called = true;
    lastUpdatedPassword = newPassword;
  }

  @override
  Future<void> completeRecovery() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  test('connected config fails closed without valid URL/client key', () {
    expect(() => AppConfig.parse(mode: 'connected'), throwsArgumentError);
    expect(
      () => AppConfig.parse(
        mode: 'connected',
        url: 'https://example.test',
        key: 'REPLACE_KEY',
      ),
      throwsArgumentError,
    );
    expect(() => AppConfig.parse(mode: 'typo'), throwsArgumentError);
  });
  test('search applies query, level and category together', () async {
    final search = SearchGrammar(MemoryGrammar());
    expect(
      (await search(
        query: ' MUỐN ',
        level: 'N5',
        category: 'desire',
      )).points.single.id,
      '1',
    );
    expect((await search(query: 'muốn', level: 'N4')).points, isEmpty);
    expect((await search(query: 'たこと')).points.single.id, '2');
  });
  test(
    'search retains cache origin even when filters return no matches',
    () async {
      final search = SearchGrammar(MemoryGrammar(origin: GrammarOrigin.cache));
      final result = await search(query: 'không có trong kho');
      expect(result.points, isEmpty);
      expect(result.origin, GrammarOrigin.cache);
    },
  );
  test('blank and overlong notes never reach storage', () {
    final repository = MemoryLearning();
    final save = SaveNote(repository);
    Note note(String text) => Note(
      id: 'n',
      grammarId: 'g',
      content: text,
      updatedAt: DateTime.utc(2026),
    );
    expect(() => save(note('  \n ')), throwsFormatException);
    expect(() => save(note('a' * 2001)), throwsFormatException);
    expect(repository.saved, isNull);
  });
  test(
    'note is trimmed and limit counts Unicode code points like SQL',
    () async {
      final repository = MemoryLearning();
      final save = SaveNote(repository);
      await save(
        Note(
          id: 'n',
          grammarId: 'g',
          content: '  ${'🌸' * 2000}  ',
          updatedAt: DateTime.utc(2026),
        ),
      );
      expect(repository.saved!.content.runes.length, 2000);
    },
  );
  test(
    'invalid credentials never call auth; pending email is not a session',
    () async {
      final repository = PendingConfirmationAuth();
      final authenticate = Authenticate(repository);
      await expectLater(
        authenticate('not-email', 'password123'),
        throwsFormatException,
      );
      expect(repository.called, isFalse);
      expect(
        await authenticate('a@example.test', 'password123', register: true),
        isFalse,
      );
    },
  );
  test(
    'resend confirmation, password reset and update password validate inputs cleanly',
    () async {
      final repository = PendingConfirmationAuth();
      final resend = ResendConfirmation(repository);
      final reset = RequestPasswordReset(repository);
      final update = UpdatePassword(repository);

      await expectLater(resend('bad'), throwsFormatException);
      await expectLater(reset('bad'), throwsFormatException);
      await expectLater(update('short'), throwsFormatException);
      expect(repository.called, isFalse);

      await resend('  user@example.test ');
      expect(repository.resendCount, 1);
      expect(repository.lastEmail, 'user@example.test');

      await reset(' reset@example.test  ');
      expect(repository.resetCount, 1);
      expect(repository.lastEmail, 'reset@example.test');

      await update('Bunly2026!secure');
      expect(repository.lastUpdatedPassword, 'Bunly2026!secure');
    },
  );
  test(
    'LocalAppSettingsRepository persists theme preference without polluting learning summary or sync outbox',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final settings = LocalAppSettingsRepository(db);
      final learning = LocalLearningRepository(
        db,
        namespace: 'demo',
        ownerId: 'demo-user',
        queueRemote: false,
      );

      expect(await settings.loadThemePreference(), AppThemePreference.system);
      await settings.saveThemePreference(AppThemePreference.dark);
      expect(await settings.loadThemePreference(), AppThemePreference.dark);
      await settings.saveThemePreference(AppThemePreference.light);
      expect(await settings.loadThemePreference(), AppThemePreference.light);

      final summary = await learning.watchSummary().first;
      expect(summary.saved, isEmpty);
      expect(summary.statuses, isEmpty);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
}
