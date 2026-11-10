/// Pure-Dart heuristic post-processor for Japanese OCR output (M3-FR-01).
///
/// Cleans common ML Kit Japanese text recognition artifacts:
/// 1. Normalizes CRLF/CR line endings and full-width ASCII alphanumerics.
/// 2. Normalizes half-width katakana punctuation (`｡､｢｣･ｰ`) and wave dashes.
/// 3. Removes spurious intra-line spaces injected between Japanese characters
///    (Kanji, Hiragana, Katakana, CJK punctuation) while preserving spaces
///    between Latin words.
/// 4. Merges broken mid-sentence line wraps while preserving paragraph breaks
///    (`\n\n`) and lines that end with sentence-final punctuation (`。！？`).
/// 5. Splits multi-sentence paragraphs into candidate sentences for review.
class JapaneseOcrPostProcessor {
  const JapaneseOcrPostProcessor();

  // Matches any Japanese character (Hiragana, Katakana, CJK Unified Ideographs,
  // CJK punctuation/brackets, prolonged sound mark, wave dash).
  static const String _jpCharClass =
      r'\u3000-\u303F\u3040-\u309F\u30A0-\u30FF\u31F0-\u31FF\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\uFF01-\uFF60';

  static final RegExp _intraJpSpacePattern = RegExp(
    '([$_jpCharClass])[ \\t\\u3000]+([$_jpCharClass])',
  );

  static final RegExp _jpBeforeAsciiPeriodPattern = RegExp(
    '([$_jpCharClass])[ \\t]*(?:\\.|．)(?=\\s|\$)',
    multiLine: true,
  );

  static final RegExp _jpBeforeAsciiBangQuestionPattern = RegExp(
    '([$_jpCharClass])[ \\t]*([!?])(?=\\s|\$)',
    multiLine: true,
  );

  static final RegExp _multiHorizontalSpacePattern = RegExp(r'[ \t]{2,}');

  static final RegExp _sentenceEndingPattern = RegExp(r'[。！？!?」』）\)]$');

  static final RegExp _startsWithJpPattern = RegExp('^[$_jpCharClass]');

  static final RegExp _endsWithJpOrCommaPattern = RegExp('[$_jpCharClass、，]\$');

  static final RegExp _sentenceSplitPattern = RegExp(r'[^。！？\n]+[。！？]?|\n+');

  /// Normalizes a full OCR text block or paragraph.
  static String normalize(String raw, {bool mergeBrokenLines = true}) {
    if (raw.isEmpty) return '';

    // 1. Standardize line endings and trim outer whitespace.
    var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (text.isEmpty) return '';

    // 2. Character-level normalization (full-width ASCII, half-width punctuation).
    text = _normalizeCharacters(text);

    // 3. Normalize each line individually.
    final rawLines = text.split('\n');
    final cleanedLines = <String>[
      for (final line in rawLines) normalizeLine(line),
    ];

    // 4. Collapse 3+ consecutive newlines (2+ empty lines) to a single blank line.
    final collapsed = <String>[];
    var consecutiveEmpty = 0;
    for (final line in cleanedLines) {
      if (line.isEmpty) {
        consecutiveEmpty++;
        if (consecutiveEmpty == 1) {
          collapsed.add('');
        }
      } else {
        consecutiveEmpty = 0;
        collapsed.add(line);
      }
    }

    while (collapsed.isNotEmpty && collapsed.first.isEmpty) {
      collapsed.removeAt(0);
    }
    while (collapsed.isNotEmpty && collapsed.last.isEmpty) {
      collapsed.removeLast();
    }
    if (collapsed.isEmpty) return '';

    if (!mergeBrokenLines) {
      return collapsed.join('\n');
    }

    // 5. Merge broken mid-sentence line wraps while preserving paragraph breaks
    //    (\n\n) and lines ending with sentence-terminal punctuation (。！？).
    final buffer = StringBuffer();
    for (var i = 0; i < collapsed.length; i++) {
      final current = collapsed[i];
      if (current.isEmpty) {
        buffer.write('\n\n');
        continue;
      }
      buffer.write(current);

      if (i + 1 < collapsed.length && collapsed[i + 1].isNotEmpty) {
        final next = collapsed[i + 1];
        final shouldMerge =
            !_sentenceEndingPattern.hasMatch(current) &&
            _endsWithJpOrCommaPattern.hasMatch(current) &&
            _startsWithJpPattern.hasMatch(next);
        if (!shouldMerge) {
          buffer.write('\n');
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Normalizes a single OCR line without newline merging.
  static String normalizeLine(String rawLine) {
    var line = rawLine.replaceAll('\r', '').trim();
    if (line.isEmpty) return '';

    line = _normalizeCharacters(line);

    // Repeatedly strip spaces between Japanese characters (2 passes handle A B C).
    var previous = '';
    while (previous != line) {
      previous = line;
      line = line.replaceAllMapped(
        _intraJpSpacePattern,
        (m) => '${m.group(1)}${m.group(2)}',
      );
    }

    // Convert trailing ASCII period/question/exclamation after Japanese text.
    line = line.replaceAllMapped(
      _jpBeforeAsciiPeriodPattern,
      (m) => '${m.group(1)}。',
    );
    line = line.replaceAllMapped(_jpBeforeAsciiBangQuestionPattern, (m) {
      final punct = m.group(2) == '?' ? '？' : '！';
      return '${m.group(1)}$punct';
    });

    // Collapse multiple ASCII spaces between Latin words to a single space.
    line = line.replaceAll(_multiHorizontalSpacePattern, ' ').trim();
    return line;
  }

  /// Splits normalized OCR text into individual candidate Japanese sentences.
  static List<String> splitSentences(String normalizedText) {
    final clean = normalizedText.trim();
    if (clean.isEmpty) return const [];

    final sentences = <String>[];
    for (final match in _sentenceSplitPattern.allMatches(clean)) {
      final segment = match.group(0)?.trim() ?? '';
      if (segment.isNotEmpty) {
        sentences.add(segment);
      }
    }
    return List.unmodifiable(sentences);
  }

  /// Returns true if post-processing meaningfully cleaned intra-CJK spaces,
  /// broken lines, or half-width/full-width punctuation beyond basic trim.
  static bool wasModifiedByPostProcessing(String raw, String normalized) {
    final basicTrim = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
    return basicTrim != normalized;
  }

  static String _normalizeCharacters(String input) {
    final sb = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      // Full-width ASCII digits ０-９ (FF10-FF19) and letters Ａ-Ｚ (FF21-FF3A), ａ-ｚ (FF41-FF5A)
      if ((code >= 0xFF10 && code <= 0xFF19) ||
          (code >= 0xFF21 && code <= 0xFF3A) ||
          (code >= 0xFF41 && code <= 0xFF5A)) {
        sb.writeCharCode(code - 0xFEE0);
        continue;
      }
      switch (code) {
        case 0x3000: // Ideographic space -> normal space (stripped if between JP)
          sb.write(' ');
        case 0xFF61: // ｡ -> 。
          sb.write('。');
        case 0xFF64: // ､ -> 、
          sb.write('、');
        case 0xFF62: // ｢ -> 「
          sb.write('「');
        case 0xFF63: // ｣ -> 」
          sb.write('」');
        case 0xFF65: // ･ -> ・
          sb.write('・');
        case 0xFF70: // ｰ -> ー
          sb.write('ー');
        case 0xFF5E: // ～ -> 〜 (wave dash used in Bunly catalog)
          sb.write('〜');
        default:
          sb.writeCharCode(code);
      }
    }
    return sb.toString();
  }
}
