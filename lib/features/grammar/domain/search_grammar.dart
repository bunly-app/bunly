import 'grammar_point.dart';
import 'grammar_repository.dart';

class SearchGrammar {
  const SearchGrammar(this.repository);
  final GrammarRepository repository;

  Future<List<GrammarPoint>> call({
    String query = '',
    String? level,
    String? category,
  }) async {
    final points = await repository.load();
    return filterGrammar(
      points,
      query: query,
      level: level,
      category: category,
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
