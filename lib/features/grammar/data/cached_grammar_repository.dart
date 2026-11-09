import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../domain/grammar_catalog.dart';
import '../domain/grammar_repository.dart';
import 'grammar_mapper.dart';
import 'grammar_sources.dart';

class CachedGrammarRepository implements GrammarRepository {
  CachedGrammarRepository(this.database, this.source, this.namespace);
  final AppDatabase database;
  final GrammarSource source;
  final String namespace;
  @override
  Future<GrammarCatalog> load() async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await source.fetch();
    } catch (error) {
      if (error is AuthException ||
          (error is PostgrestException &&
              (error.code == '42501' ||
                  error.code?.startsWith('PGRST3') == true))) {
        rethrow;
      }
      final cached = await (database.select(
        database.cachedGrammar,
      )..where((t) => t.namespace.equals(namespace))).get();
      if (cached.isEmpty) rethrow;
      return GrammarCatalog(
        cached.map(
          (row) =>
              grammarFromJson(jsonDecode(row.payload) as Map<String, dynamic>),
        ),
        origin: GrammarOrigin.cache,
      );
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
    return GrammarCatalog(
      rows.map(grammarFromJson),
      origin: GrammarOrigin.source,
    );
  }
}
