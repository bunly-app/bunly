import '../../grammar/domain/grammar_point.dart';
import 'grammar_analysis.dart';

enum OnDeviceMatchSource { exactExample, morphologicalRule }

class OnDeviceGrammarMatch {
  const OnDeviceGrammarMatch({
    required this.point,
    this.span,
    required this.confidence,
    required this.source,
  });

  final GrammarPoint point;
  final AnalysisUtf16Span? span;
  final double confidence;
  final OnDeviceMatchSource source;

  int get confidencePercent => (confidence * 100).round().clamp(1, 100);
}

class OnDeviceDetectionResult {
  OnDeviceDetectionResult({
    required this.text,
    required List<OnDeviceGrammarMatch> matches,
    required this.latencyMs,
  }) : matches = List.unmodifiable(matches);

  final String text;
  final List<OnDeviceGrammarMatch> matches;
  final int latencyMs;

  List<GrammarPoint> get points =>
      List.unmodifiable(matches.map((m) => m.point));

  List<String> get candidateGrammarIds =>
      List.unmodifiable(matches.map((m) => m.point.id));
}

enum _RuleTier { compound, structural, basic }

class _GrammarDetectionRule {
  _GrammarDetectionRule({
    required this.idSuffix,
    required this.canonicalPattern,
    required this.anchors,
    required List<String> regexes,
    required this.confidence,
    required this.tier,
    this.expandStemLeft = true,
    this.suppressesIds = const {},
  }) : compiledRegexes = List.unmodifiable([
         for (final r in regexes) RegExp(r),
       ]);

  final String idSuffix;
  final String canonicalPattern;
  final List<String> anchors;
  final List<RegExp> compiledRegexes;
  final double confidence;
  final _RuleTier tier;
  final bool expandStemLeft;
  final Set<String> suppressesIds;

  String get fullId => '10000000-0000-0000-0000-$idSuffix';
}

/// Pure-Dart on-device Japanese grammar detector (M3-FR-03 & M3-FR-04).
///
/// Works 100% offline (Airplane Mode) in < 5 ms using substring anchor
/// pre-filtering, morpheme-anchored regex rules, particle-aware stem boundary
/// expansion, and UTF-16 span suppression across Bunly's 90 N5/N4 patterns.
class OnDeviceGrammarDetector {
  const OnDeviceGrammarDetector({this.maxMatches = 5});

  final int maxMatches;

  static const String _np = r'[一-龯ぁ-んァ-ヶー0-9０-９]{1,8}';

  static final List<_GrammarDetectionRule> _rules = [
    // =========================================================================
    // TIER 1: High-specificity compound constructions (0.90 - 0.96)
    // =========================================================================
    _GrammarDetectionRule(
      idSuffix: '000000000001',
      canonicalPattern: '〜たことがある',
      anchors: const ['ことが'],
      confidence: 0.96,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000026', '000000000031'},
      regexes: [r'(?:った|いた|いだ|した|んだ|た|だ)ことが(?:あり(?:ます|ません|ました)|ある|ない|あった)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000006',
      canonicalPattern: '〜なければならない',
      anchors: const ['なければ'],
      confidence: 0.96,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000065', '000000000066'},
      regexes: [r'なければ(?:なりません|ならない|いけません|いけない)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000007',
      canonicalPattern: '〜なくてもいい',
      anchors: const ['なくても'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000004', '000000000070'},
      regexes: [r'なくても(?:いい|よい)(?:ですか|です|か)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000004',
      canonicalPattern: '〜てもいい',
      anchors: const ['てもいい', 'でもいい', 'てもよい', 'でもよい'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000070'},
      regexes: [r'(?:て|で)も(?:いい|よい)(?:ですか|です|か)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000005',
      canonicalPattern: '〜てはいけない',
      anchors: const ['てはいけ', 'ではいけ'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      regexes: [r'(?:て|で)はいけ(?:ません|ない)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000011',
      canonicalPattern: '〜ことができる',
      anchors: const ['ことができ'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      regexes: [r'ことができ(?:ます|ません|ました|る|ない|た)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000038',
      canonicalPattern: '〜ないでください',
      anchors: const ['ないでください'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000037', '000000000061'},
      regexes: [r'ないでください'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000037',
      canonicalPattern: '〜てください',
      anchors: const ['てください', 'でください'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'(?:て|で)ください'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000042',
      canonicalPattern: '〜たほうがいい',
      anchors: const ['ほうがいい', '方がいい', 'ほうがよい', '方がよい'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000031'},
      regexes: [r'(?:た|だ|ない)(?:ほう|方)が(?:いい|よい)(?:ですよ|ですか|です)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000010',
      canonicalPattern: '〜より〜のほうが',
      anchors: const ['より'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      expandStemLeft: false,
      regexes: ['$_npより$_npの(?:ほう|方)が'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000046',
      canonicalPattern: '〜の中で〜がいちばん',
      anchors: const ['の中で'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      expandStemLeft: false,
      regexes: ['$_npの中で$_npが(?:いちばん|一番)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000067',
      canonicalPattern: '〜たらどうですか',
      anchors: const ['たらどうですか', 'だらどうですか'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000064'},
      regexes: [r'(?:たら|だら)どうですか'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000080',
      canonicalPattern: '〜ようと思う',
      anchors: const ['ようと思', 'おうと思'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000083', '000000000003'},
      regexes: [r'(?:よう|おう)と思(?:っています|っていました|います|いました|う|った)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000082',
      canonicalPattern: '〜ことにする・〜ことになる',
      anchors: const ['ことにし', 'ことにす', 'ことにな'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000034'},
      regexes: [r'ことに(?:しました|します|する|なりました|なります|なる|なっています|なっている)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000090',
      canonicalPattern: '〜かもしれない',
      anchors: const ['かもしれ'],
      confidence: 0.95,
      tier: _RuleTier.compound,
      regexes: [r'かもしれ(?:ません|ない)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000085',
      canonicalPattern: '〜かどうか',
      anchors: const ['かどうか'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      regexes: [r'かどうか'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000008',
      canonicalPattern: '〜つもりだ',
      anchors: const ['つもり'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'つもり(?:です|だ|でした|だった|はない|はありません)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000081',
      canonicalPattern: '〜予定だ',
      anchors: const ['予定'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'予定(?:です|だ|でした|だった)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000059',
      canonicalPattern: '〜たばかり',
      anchors: const ['たばかり', 'だばかり'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000031'},
      regexes: [r'(?:た|だ)ばかり(?:です|だ|でした|だった)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000060',
      canonicalPattern: '〜ところだ',
      anchors: const ['ところ'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'(?:る|ている|た|だ)ところ(?:です|だ|でした|だった)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000055',
      canonicalPattern: '〜てしまう',
      anchors: const ['てしま', 'でしま'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'(?:て|で)しま(?:いました|います|った|う)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000054',
      canonicalPattern: '〜ておく',
      anchors: const ['ておき', 'ておい', 'ておく', 'でおき', 'でおい', 'でおく'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000037'},
      regexes: [r'(?:て|で)お(?:いてください|きます|きました|く|いた)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000053',
      canonicalPattern: '〜てある',
      anchors: const ['てあり', 'であり', 'てある', 'である'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000026'},
      regexes: [r'(?:て|で)(?:あります|ありました|ある)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000077',
      canonicalPattern: '〜てみる',
      anchors: const ['てみ', 'でみ'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000002', '000000000037'},
      regexes: [r'(?:て|で)み(?:たいです|たい|てください|たらどうですか|ました|ます|る|た)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000079',
      canonicalPattern: '〜てほしい',
      anchors: const ['てほしい', 'でほしい', 'て欲しい', 'で欲しい'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000047'},
      regexes: [r'(?:て|で)(?:ほしい|欲しい)(?:です)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000088',
      canonicalPattern: '〜てあげる・〜てもらう・〜てくれる',
      anchors: const ['てあげ', 'てもら', 'てくれ', 'であげ', 'でもら', 'でくれ'],
      confidence: 0.94,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000050'},
      regexes: [r'(?:て|で)(?:あげ|もら|くれ)(?:ました|ます|たいです|たい|る|た)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000056',
      canonicalPattern: '〜てくる・〜ていく',
      anchors: const ['てきま', 'ていき', 'てきた', 'ていく', 'できま', 'でいき'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'(?:て|で)(?:きました|きます|いきます|いきました|きた|いく)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000057',
      canonicalPattern: '〜はじめる・〜おわる',
      anchors: const ['はじめ', 'おわ', '始め', '終わ'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [
        r'(?:はじめ(?:ました|ます|る|た)|おわ(?:りました|ります|る|った)|始め(?:ました|ます|る|た)|終わ(?:りました|ります|る|った))',
      ],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000058',
      canonicalPattern: '〜つづける',
      anchors: const ['つづけ', '続け'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000002'},
      regexes: [r'(?:つづけ|続け)(?:ました|ます|たいです|たい|る|た)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000073',
      canonicalPattern: '〜すぎる',
      anchors: const ['すぎ', '過ぎ'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'(?:すぎ(?:てしまいました|ました|ます|て|る|た)|過ぎ(?:ました|ます|て|る|た))'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000074',
      canonicalPattern: '〜やすい・〜にくい',
      anchors: const ['やすい', 'にくい'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      regexes: [r'(?:やすい|にくい)(?:です|ですか)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000075',
      canonicalPattern: '〜そうだ（様態）',
      anchors: const ['そう'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'(?:そう(?:ですね|です|だ|な)|よさそう|なさそう)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000076',
      canonicalPattern: '〜がる',
      anchors: const ['がって', 'がる', 'がった'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000003'},
      regexes: [r'が(?:っています|っていました|る|った)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000078',
      canonicalPattern: '〜なさい',
      anchors: const ['なさい'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'なさい'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000051',
      canonicalPattern: '〜まえに',
      anchors: const ['まえに', '前に'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'(?:の)?(?:まえ|前)に'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000012',
      canonicalPattern: '〜てから',
      anchors: const ['てから', 'でから'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'(?:て|で)から'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000030',
      canonicalPattern: '〜ていない',
      anchors: const ['ていま', 'ていな', 'でいま', 'でいな'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000003'},
      regexes: [r'(?:て|で)い(?:ません|ない)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000062',
      canonicalPattern: '〜ずに',
      anchors: const ['ずに'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'ずに'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000086',
      canonicalPattern: '〜ために',
      anchors: const ['ために'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'(?:の)?ために'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000087',
      canonicalPattern: '〜ように',
      anchors: const ['ように'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'ように'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000024',
      canonicalPattern: '〜から〜まで',
      anchors: const ['まで'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      expandStemLeft: false,
      regexes: ['$_npから$_npまで'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000025',
      canonicalPattern: '〜や〜など',
      anchors: const ['や'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      expandStemLeft: false,
      regexes: ['$_npや$_np(?:など)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000047',
      canonicalPattern: '〜がほしい',
      anchors: const ['ほしい', '欲しい'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'が(?:ほしい|欲しい)(?:です|ですか)?|(?:いちばん|一番)(?:ほしい|欲しい)もの'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000039',
      canonicalPattern: '〜ませんか',
      anchors: const ['ませんか'],
      confidence: 0.92,
      tier: _RuleTier.compound,
      regexes: [r'ませんか'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000041',
      canonicalPattern: '〜ましょうか',
      anchors: const ['ましょうか'],
      confidence: 0.93,
      tier: _RuleTier.compound,
      suppressesIds: {'000000000040'},
      regexes: [r'ましょうか'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000040',
      canonicalPattern: '〜ましょう',
      anchors: const ['ましょう'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'ましょう(?!か)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000014',
      canonicalPattern: '〜ではありません',
      anchors: const ['ではありませ', 'じゃありませ'],
      confidence: 0.91,
      tier: _RuleTier.compound,
      regexes: [r'(?:では|じゃ)あり(?:ません|ませんでした)'],
    ),

    // =========================================================================
    // TIER 2: Structural & Conjugation patterns (0.80 - 0.89)
    // =========================================================================
    _GrammarDetectionRule(
      idSuffix: '000000000002',
      canonicalPattern: '〜たい',
      anchors: const ['たい'],
      confidence: 0.89,
      tier: _RuleTier.structural,
      regexes: [r'たい(?:ですか|です|と思います|な)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000003',
      canonicalPattern: '〜ている',
      anchors: const ['ていま', 'でいま', 'ている', 'でいる'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'(?:て|で)い(?:ます|ました|る)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000009',
      canonicalPattern: '〜ながら',
      anchors: const ['ながら'],
      confidence: 0.89,
      tier: _RuleTier.structural,
      regexes: [r'ながら'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000083',
      canonicalPattern: '〜と思う',
      anchors: const ['と思', 'どう思'],
      confidence: 0.88,
      tier: _RuleTier.structural,
      regexes: [r'(?<!よう|おう)(?:と|どう)思(?:いますか|います|いました|う)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000084',
      canonicalPattern: '〜と言う',
      anchors: const ['と言'],
      confidence: 0.89,
      tier: _RuleTier.structural,
      regexes: [r'と言(?:いました|っていました|います|う|った)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000068',
      canonicalPattern: '〜ので',
      anchors: const ['ので'],
      confidence: 0.87,
      tier: _RuleTier.structural,
      regexes: [r'ので'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000069',
      canonicalPattern: '〜のに',
      anchors: const ['のに'],
      confidence: 0.88,
      tier: _RuleTier.structural,
      regexes: [r'のに'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000070',
      canonicalPattern: '〜ても',
      anchors: const ['ても', 'くても'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'(?:ても|くても)(?!いい|よい)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000071',
      canonicalPattern: '〜し、〜し',
      anchors: const ['し、'],
      confidence: 0.89,
      tier: _RuleTier.structural,
      regexes: [r'し、[^。]+し'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000064',
      canonicalPattern: '〜たら',
      anchors: const ['たら', 'だら'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'(?:ったら|いたら|いだら|したら|んだら|たら|だら)(?!どうですか)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000065',
      canonicalPattern: '〜ば',
      anchors: const ['れば', 'けば', 'げば', 'せば', 'てば', 'ねば', 'べば', 'めば', 'えば'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'(?:れば|けば|げば|せば|てば|ねば|べば|めば|えば|ければ)(?!なら|いけ)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000066',
      canonicalPattern: '〜なら',
      anchors: const ['なら'],
      confidence: 0.85,
      tier: _RuleTier.structural,
      regexes: [r'なら(?!ない|ば)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000063',
      canonicalPattern: '〜と（条件）',
      anchors: const ['と、'],
      confidence: 0.84,
      tier: _RuleTier.structural,
      regexes: [r'(?:る|く|ぐ|す|つ|ぬ|ぶ|む|う|ない)と、'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000061',
      canonicalPattern: '〜ないで',
      anchors: const ['ないで'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'ないで(?!ください)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000048',
      canonicalPattern: '〜の（名詞化）',
      anchors: const ['のが', 'のは'],
      confidence: 0.87,
      tier: _RuleTier.structural,
      suppressesIds: {'000000000036'},
      regexes: [r'(?:る|く|ぐ|す|つ|ぬ|ぶ|む|う)の(?:が好き|が上手|が下手|が速い|は大変|は難しい|は楽しい)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000036',
      canonicalPattern: '〜が好きだ・〜が上手だ',
      anchors: const ['が好き', 'が嫌い', 'が上手', 'が下手'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'が(?:好き|嫌い|上手|下手)(?:ですね|です|だ)?'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000034',
      canonicalPattern: '〜くなる・〜になる',
      anchors: const ['くなり', 'になり', 'くなる', 'になる', 'くなった', 'になった'],
      confidence: 0.85,
      tier: _RuleTier.structural,
      regexes: [r'(?<!ことに)(?:く|に)な(?:りました|ります|る|った)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000049',
      canonicalPattern: '〜に行く・来る',
      anchors: const ['に行き', 'に行く', 'に来ま', 'に来る'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'に(?:行きます|行きました|行きませんか|行く|来ます|来ました|来る)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000050',
      canonicalPattern: '〜あげる・〜もらう・〜くれる',
      anchors: const ['をあげ', 'をもら', 'をくれ'],
      confidence: 0.86,
      tier: _RuleTier.structural,
      regexes: [r'を(?:あげました|あげます|もらいました|もらいます|くれました|くれます)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000026',
      canonicalPattern: '〜に〜がある',
      anchors: const ['があり'],
      confidence: 0.84,
      tier: _RuleTier.structural,
      regexes: [r'(?<!ことが)があり(?:ます|ません|ました)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000027',
      canonicalPattern: '〜に〜がいる',
      anchors: const ['がいま', 'がいませ', '誰もいま'],
      confidence: 0.85,
      tier: _RuleTier.structural,
      regexes: [r'(?:が|誰も)い(?:ます|ません|ました)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000052',
      canonicalPattern: '可能形（〜られる・〜える）',
      anchors: const [
        '読め',
        '泳げ',
        '話せ',
        '書け',
        '買え',
        '行け',
        '飲め',
        '食べられ',
        '見られ',
        '来られ',
      ],
      confidence: 0.85,
      tier: _RuleTier.structural,
      regexes: [
        r'(?:読め|泳げ|話せ|書け|買え|行け|飲め|食べられ|見られ|来られ)(?:ます|ません|ました|る|ない|るように)',
      ],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000089',
      canonicalPattern: '受身形（〜られる・〜れる）',
      anchors: const [
        'ほめられ',
        '踏まれ',
        '叱られ',
        '呼ばれ',
        '頼まれ',
        '誘われ',
        '盗まれ',
        '笑われ',
        '言われ',
      ],
      confidence: 0.85,
      tier: _RuleTier.structural,
      regexes: [r'(?:ほめられ|踏まれ|叱られ|呼ばれ|頼まれ|誘われ|盗まれ|笑われ|言われ)(?:ました|ます|た)'],
    ),

    // =========================================================================
    // TIER 3: Basic N5 clause, adjective, particle & tense patterns (0.68 - 0.78)
    // =========================================================================
    _GrammarDetectionRule(
      idSuffix: '000000000043',
      canonicalPattern: '〜から（理由）',
      anchors: const ['から、'],
      confidence: 0.78,
      tier: _RuleTier.basic,
      regexes: [r'(?:ます|ません|です|い|だ|た)から、'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000044',
      canonicalPattern: '〜が・〜けれども',
      anchors: const ['ですが', 'けれども', 'すみませんが'],
      confidence: 0.78,
      tier: _RuleTier.basic,
      regexes: [r'(?:ですが|ますけれど|けれども|すみませんが)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000045',
      canonicalPattern: '〜て・〜で（順接）',
      anchors: const ['て、', 'で、'],
      confidence: 0.77,
      tier: _RuleTier.basic,
      regexes: [r'(?:て|で)、[^。]+(?:て|で)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000072',
      canonicalPattern: '〜て（原因・理由）',
      anchors: const ['て、', 'で、'],
      confidence: 0.78,
      tier: _RuleTier.basic,
      regexes: [r'(?:て|で)、(?:びっくり|安心|心配|困|遅れ)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000032',
      canonicalPattern: 'い形容詞（〜い・〜くない）',
      anchors: const ['くない', 'くありませ'],
      confidence: 0.76,
      tier: _RuleTier.basic,
      regexes: [r'(?:くないです|くない|くありません)'],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000033',
      canonicalPattern: 'な形容詞（〜だ・〜ではない）',
      anchors: const ['静か', '有名', 'きれい', '親切', '賑やか', '便利', '暇'],
      confidence: 0.76,
      tier: _RuleTier.basic,
      regexes: [
        r'(?:静かな|有名な|きれいな|親切な|賑やかな|便利な|暇な)|(?:静か|有名|きれい|親切|賑やか|便利|暇)ではありません',
      ],
    ),
    _GrammarDetectionRule(
      idSuffix: '000000000035',
      canonicalPattern: '〜くて・〜で',
      anchors: const ['くて', '親切で', '静かで', 'きれいで', '有名で', '便利で', '元気で'],
      confidence: 0.77,
      tier: _RuleTier.basic,
      regexes: [r'くて|(?:親切|静か|きれい|有名|便利|元気)で'],
    ),
  ];

  // Particles and delimiters where leftward verb/adjective stem expansion stops.
  static const Set<int> _stemStopCodeUnits = {
    0x306F, // は
    0x304C, // が
    0x3092, // を
    0x306B, // に
    0x3078, // へ
    0x3067, // で
    0x3068, // と
    0x3082, // も
    0x3084, // や
    0x3001, // 、
    0x3002, // 。
    0x300C, // 「
    0x300D, // 」
    0x0020, // space
    0x3000, // full-width space
    0x000A, // \n
  };

  /// Detects grammar patterns on-device for [rawText] against [catalogPoints].
  OnDeviceDetectionResult detect(
    String rawText,
    List<GrammarPoint> catalogPoints,
  ) {
    final rules = _rules;
    final stopwatch = Stopwatch()..start();
    final text = normalizeAnalysisText(rawText);
    if (text.isEmpty || catalogPoints.isEmpty) {
      stopwatch.stop();
      return OnDeviceDetectionResult(
        text: text,
        matches: const [],
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    }

    final byId = <String, GrammarPoint>{
      for (final p in catalogPoints) p.id.toLowerCase(): p,
    };
    final byPattern = <String, GrammarPoint>{
      for (final p in catalogPoints) p.pattern.trim(): p,
    };

    final rawCandidates =
        <
          ({
            GrammarPoint point,
            AnalysisUtf16Span? span,
            double confidence,
            OnDeviceMatchSource source,
            _RuleTier tier,
            String? ruleIdSuffix,
            Set<String> suppressesIds,
          })
        >[];

    // 1. Check exact example matches first (highest confidence: 0.98).
    final exactMatchedPointIds = <String>{};
    for (final point in catalogPoints) {
      final hasExactExample = point.examples.any(
        (ex) => normalizeAnalysisText(ex.japanese) == text,
      );
      if (hasExactExample) {
        exactMatchedPointIds.add(point.id);
        final rule = _findRuleForPoint(point);
        final span = _extractRuleSpan(text, point, rule);
        rawCandidates.add((
          point: point,
          span: span,
          confidence: 0.98,
          source: OnDeviceMatchSource.exactExample,
          tier: rule?.tier ?? _RuleTier.compound,
          ruleIdSuffix: rule?.idSuffix,
          suppressesIds: rule?.suppressesIds ?? const {},
        ));
      }
    }

    // 2. Run morphological/surface regex rules across the catalog, gated by
    //    fast O(1) substring anchor checks.
    for (final rule in rules) {
      if (!rule.anchors.any(text.contains)) {
        continue;
      }
      final point = byId[rule.fullId] ?? byPattern[rule.canonicalPattern];
      if (point == null || exactMatchedPointIds.contains(point.id)) {
        continue;
      }
      final span = _matchFirstRegexSpan(
        text,
        rule.compiledRegexes,
        expandStemLeft: rule.expandStemLeft,
      );
      if (span != null) {
        rawCandidates.add((
          point: point,
          span: span,
          confidence: rule.confidence,
          source: OnDeviceMatchSource.morphologicalRule,
          tier: rule.tier,
          ruleIdSuffix: rule.idSuffix,
          suppressesIds: rule.suppressesIds,
        ));
      }
    }

    // 3. Apply explicit suppression sets and span-containment deduplication.
    final suppressedSuffixes = <String>{
      for (final c in rawCandidates) ...c.suppressesIds,
    };

    final hasCompoundOrStructural = rawCandidates.any(
      (c) => c.tier == _RuleTier.compound || c.tier == _RuleTier.structural,
    );

    final afterRuleSuppression = rawCandidates.where((c) {
      if (c.source == OnDeviceMatchSource.exactExample) return true;
      if (c.ruleIdSuffix != null &&
          suppressedSuffixes.contains(c.ruleIdSuffix)) {
        return false;
      }
      if (hasCompoundOrStructural && c.tier == _RuleTier.basic) {
        return false;
      }
      return true;
    }).toList();

    // Sort by confidence descending, then span length descending.
    afterRuleSuppression.sort((a, b) {
      final confCmp = b.confidence.compareTo(a.confidence);
      if (confCmp != 0) return confCmp;
      final lenA = a.span == null ? 0 : (a.span!.endUtf16 - a.span!.startUtf16);
      final lenB = b.span == null ? 0 : (b.span!.endUtf16 - b.span!.startUtf16);
      return lenB.compareTo(lenA);
    });

    final accepted = <OnDeviceGrammarMatch>[];
    final acceptedSpans = <AnalysisUtf16Span>[];
    for (final candidate in afterRuleSuppression) {
      if (accepted.length >= maxMatches) break;
      final span = candidate.span;
      if (span != null &&
          candidate.source != OnDeviceMatchSource.exactExample) {
        final isSubSpanOfHigher = acceptedSpans.any(
          (existing) =>
              span.startUtf16 >= existing.startUtf16 &&
              span.endUtf16 <= existing.endUtf16,
        );
        if (isSubSpanOfHigher) continue;
      }
      if (span != null) {
        acceptedSpans.add(span);
      }
      accepted.add(
        OnDeviceGrammarMatch(
          point: candidate.point,
          span: span,
          confidence: candidate.confidence,
          source: candidate.source,
        ),
      );
    }

    stopwatch.stop();
    return OnDeviceDetectionResult(
      text: text,
      matches: accepted,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }

  _GrammarDetectionRule? _findRuleForPoint(GrammarPoint point) {
    final lowerId = point.id.toLowerCase();
    for (final rule in _rules) {
      if (rule.fullId == lowerId || rule.canonicalPattern == point.pattern) {
        return rule;
      }
    }
    return null;
  }

  AnalysisUtf16Span? _extractRuleSpan(
    String text,
    GrammarPoint point,
    _GrammarDetectionRule? rule,
  ) {
    if (rule != null) {
      final byRule = _matchFirstRegexSpan(
        text,
        rule.compiledRegexes,
        expandStemLeft: rule.expandStemLeft,
      );
      if (byRule != null) return byRule;
    }
    // Fallback literal extraction from pattern (strip 〜 and parenthetical notes).
    final cleanedPattern = point.pattern
        .replaceAll(RegExp(r'（[^）]*）'), '')
        .split('・')
        .map((s) => s.replaceAll('〜', '').trim())
        .where((s) => s.isNotEmpty);
    for (final token in cleanedPattern) {
      final idx = text.indexOf(token);
      if (idx >= 0) {
        final start = _expandLeft(text, idx);
        final end = idx + token.length;
        final validated = validateSpanOnText(
          text,
          startUtf16: start,
          endUtf16: end,
          spanText: text.substring(start, end),
        );
        if (validated != null) return validated;
      }
    }
    return null;
  }

  AnalysisUtf16Span? _matchFirstRegexSpan(
    String text,
    List<RegExp> compiledRegexes, {
    required bool expandStemLeft,
  }) {
    for (final regExp in compiledRegexes) {
      for (final match in regExp.allMatches(text)) {
        if (match.start >= match.end) continue;
        final start = expandStemLeft
            ? _expandLeft(text, match.start)
            : match.start;
        final end = match.end;
        final spanText = text.substring(start, end);
        final validated = validateSpanOnText(
          text,
          startUtf16: start,
          endUtf16: end,
          spanText: spanText,
        );
        if (validated != null) {
          return validated;
        }
      }
    }
    return null;
  }

  /// Expands left from a grammar suffix start index by up to 5 Kanji/Kana code
  /// units to include the verb/adjective/noun stem, stopping at particles or
  /// punctuation and respecting UTF-16 surrogate boundaries.
  int _expandLeft(String text, int suffixStart) {
    var cursor = suffixStart;
    var steps = 0;
    while (cursor > 0 && steps < 5) {
      final prevIndex = cursor - 1;
      if (!isValidUtf16Boundary(text, prevIndex)) break;
      final unit = text.codeUnitAt(prevIndex);
      if (_stemStopCodeUnits.contains(unit)) break;
      final isJapaneseWordChar =
          (unit >= 0x3040 && unit <= 0x309F) || // Hiragana
          (unit >= 0x30A0 && unit <= 0x30FF) || // Katakana
          (unit >= 0x4E00 && unit <= 0x9FFF) || // Kanji
          (unit >= 0x3400 && unit <= 0x4DBF);
      if (!isJapaneseWordChar) break;
      cursor = prevIndex;
      steps++;
    }
    return cursor;
  }
}
