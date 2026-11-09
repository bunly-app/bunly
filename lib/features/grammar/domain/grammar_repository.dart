import 'grammar_catalog.dart';

abstract interface class GrammarRepository {
  Future<GrammarCatalog> load();
}
