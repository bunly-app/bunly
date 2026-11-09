enum PracticeKind { choice, cloze }

class PracticeQuestion {
  const PracticeQuestion({
    required this.kind,
    required this.prompt,
    required this.context,
    required this.options,
    required this.accepted,
    required this.explanation,
  });
  final PracticeKind kind;
  final String prompt;
  final String context;
  final List<String> options;
  final List<String> accepted;
  final String explanation;
  bool accepts(String answer) => accepted.contains(answer.trim());
}

class PracticeResponse {
  const PracticeResponse(this.answer, this.correct);
  final String? answer;
  final bool correct;
}

class DemoPracticeSession {
  DemoPracticeSession(List<PracticeQuestion> items)
    : questions = List.unmodifiable(items);
  final List<PracticeQuestion> questions;
  final Map<int, PracticeResponse> _responses = {};
  PracticeResponse? responseAt(int index) => _responses[index];
  int get correct => _responses.values.where((r) => r.correct).length;
  int get skipped => _responses.values.where((r) => r.answer == null).length;
  int get answered => _responses.length - skipped;
  bool submit(int index, String? answer) {
    if (index < 0 ||
        index >= questions.length ||
        _responses.containsKey(index)) {
      return false;
    }
    _responses[index] = PracticeResponse(
      answer,
      answer != null && questions[index].accepts(answer),
    );
    return true;
  }
}

abstract interface class DemoPracticeRepository {
  List<PracticeQuestion> questions();
}

class StartDemoPractice {
  const StartDemoPractice(this.repository);
  final DemoPracticeRepository repository;
  DemoPracticeSession call(Set<PracticeKind> kinds) => DemoPracticeSession(
    repository.questions().where((q) => kinds.contains(q.kind)).toList(),
  );
}
