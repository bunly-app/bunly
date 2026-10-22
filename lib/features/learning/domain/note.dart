class Note {
  const Note({
    required this.id,
    required this.grammarId,
    required this.content,
    required this.updatedAt,
  });
  final String id;
  final String grammarId;
  final String content;
  final DateTime updatedAt;
}
