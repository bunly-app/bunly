import 'package:bunly/app/config.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/auth/domain/authenticate.dart';
import 'package:bunly/features/grammar/domain/grammar_point.dart';
import 'package:bunly/features/grammar/domain/grammar_repository.dart';
import 'package:bunly/features/grammar/domain/search_grammar.dart';
import 'package:bunly/features/learning/domain/learning_repository.dart';
import 'package:bunly/features/learning/domain/note.dart';
import 'package:bunly/features/learning/domain/save_note.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryLearning implements LearningRepository {
  Note? saved;
  @override
  Future<void> saveNote(Note note) async {
    saved = note;
  }

  @override
  Stream<List<Note>> watchNotes(String grammarId) => Stream.value([]);
}

class MemoryGrammar implements GrammarRepository {
  @override
  Future<List<GrammarPoint>> load() async => [
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
  ];
}

class PendingConfirmationAuth implements AuthRepository {
  bool called = false;
  @override
  AppUser? get currentUser => null;
  @override
  Stream<AppUser?> get changes => const Stream.empty();
  @override
  Future<void> signIn(String email, String password) async {
    called = true;
  }

  @override
  Future<bool> signUp(String email, String password) async {
    called = true;
    return false;
  }

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
      )).single.id,
      '1',
    );
    expect(await search(query: 'muốn', level: 'N4'), isEmpty);
    expect((await search(query: 'たこと')).single.id, '2');
  });
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
}
