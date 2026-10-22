import '../domain/grammar_point.dart';

GrammarPoint grammarFromJson(Map<String, dynamic> json) => GrammarPoint(
  id: json['id'] as String,
  pattern: json['pattern'] as String,
  level: json['level'] as String,
  category: json['category'] as String,
  meaning: json['meaning_vi'] as String,
  formula: json['formula'] as String,
  usage: json['usage_vi'] as String,
  examples: (json['grammar_examples'] as List)
      .map(
        (e) => GrammarExample(
          e['sentence_ja'] as String,
          e['translation_vi'] as String,
        ),
      )
      .toList(growable: false),
);
