import 'dart:convert';
import '../../../core/database/app_database.dart';
import '../domain/grammar_point.dart';
import '../domain/grammar_repository.dart';
import 'grammar_mapper.dart';
import 'grammar_sources.dart';

class CachedGrammarRepository implements GrammarRepository {
  CachedGrammarRepository(this.database, this.source, this.namespace);
  final AppDatabase database;
  final GrammarSource source;
  final String namespace;

  @override
  Future<List<GrammarPoint>> load() async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await source.fetch();
    } catch (_) {
      final cached = await (database.select(
        database.cachedGrammar,
      )..where((t) => t.namespace.equals(namespace))).get();
      if (cached.isEmpty) rethrow;
      return cached
          .map(
            (row) => grammarFromJson(
              jsonDecode(row.payload) as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    // A successful empty response must clear stale cache as well.
    await database.transaction(() async {
      await (database.delete(
        database.cachedGrammar,
      )..where((t) => t.namespace.equals(namespace))).go();
      await database.batch(
        (batch) => batch.insertAll(
          database.cachedGrammar,
          rows
              .map(
                (row) => CachedGrammarCompanion.insert(
                  namespace: namespace,
                  grammarId: row['id'] as String,
                  payload: jsonEncode(row),
                ),
              )
              .toList(),
        ),
      );
    });
    return rows.map(grammarFromJson).toList();
  }
}
