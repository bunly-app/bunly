import 'grammar_point.dart';

abstract interface class GrammarRepository {
  Future<List<GrammarPoint>> load();
}
