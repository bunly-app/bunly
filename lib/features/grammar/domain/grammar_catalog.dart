import 'grammar_point.dart';

/// Identifies whether a load used the configured source or its local fallback.
enum GrammarOrigin { source, cache }

/// Keeps content and its origin together for a single completed load.
class GrammarCatalog {
  GrammarCatalog(Iterable<GrammarPoint> points, {required this.origin})
    : points = List.unmodifiable(points);

  final List<GrammarPoint> points;
  final GrammarOrigin origin;
}
