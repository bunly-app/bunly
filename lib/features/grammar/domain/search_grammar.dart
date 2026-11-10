import 'grammar_point.dart';
import 'grammar_catalog.dart';
import 'grammar_repository.dart';

class SearchGrammar {
  const SearchGrammar(this.repository);
  final GrammarRepository repository;

  Future<GrammarCatalog> call({
    String query = '',
    String? level,
    String? category,
  }) async {
    final catalog = await repository.load();
    return GrammarCatalog(
      filterGrammar(
        catalog.points,
        query: query,
        level: level,
        category: category,
      ),
      origin: catalog.origin,
    );
  }
}

List<GrammarPoint> filterGrammar(
  List<GrammarPoint> points, {
  String query = '',
  String? level,
  String? category,
}) {
  final term = query.trim().toLowerCase();
  return points
      .where(
        (p) =>
            (level == null || p.level == level) &&
            (category == null || p.category == category) &&
            (term.isEmpty ||
                '${p.pattern} ${p.meaning}'.toLowerCase().contains(term)),
      )
      .toList(growable: false);
}
