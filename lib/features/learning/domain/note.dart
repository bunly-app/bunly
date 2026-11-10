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

class NoteConflict {
  const NoteConflict({
    required this.noteId,
    required this.grammarId,
    required this.localContent,
    required this.localUpdatedAt,
    required this.remoteContent,
    required this.remoteUpdatedAt,
  });

  final String noteId;
  final String grammarId;
  final String localContent;
  final DateTime localUpdatedAt;
  final String remoteContent;
  final DateTime remoteUpdatedAt;
}
