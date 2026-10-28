import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class GrammarSource {
  Future<List<Map<String, dynamic>>> fetch();
}

class AssetGrammarSource implements GrammarSource {
  @override
  Future<List<Map<String, dynamic>>> fetch() async {
    final text = await rootBundle.loadString('assets/data/grammar.json');
    return (jsonDecode(text) as List).cast<Map<String, dynamic>>();
  }
}

class SupabaseGrammarSource implements GrammarSource {
  SupabaseGrammarSource(this.client);
  final SupabaseClient client;
  @override
  Future<List<Map<String, dynamic>>> fetch() => client
      .from('grammar_points')
      .select('*, grammar_examples(*)')
      .order('pattern');
}
