class GrammarExample {
  const GrammarExample(this.japanese, this.vietnamese);
  final String japanese;
  final String vietnamese;
}

class GrammarPoint {
  const GrammarPoint({
    required this.id,
    required this.pattern,
    required this.level,
    required this.category,
    required this.meaning,
    required this.formula,
    required this.usage,
    required this.examples,
  });
  final String id;
  final String pattern;
  final String level;
  final String category;
  final String meaning;
  final String formula;
  final String usage;
  final List<GrammarExample> examples;
}
