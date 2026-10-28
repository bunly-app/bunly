import 'learning_repository.dart';
import 'note.dart';

class SaveNote {
  const SaveNote(this.repository);
  final LearningRepository repository;

  Future<void> call(Note note) {
    final content = note.content.trim();
    if (content.isEmpty || content.runes.length > 2000) {
      throw const FormatException('Ghi chú cần từ 1 đến 2000 ký tự.');
    }
    return repository.saveNote(
      Note(
        id: note.id,
        grammarId: note.grammarId,
        content: content,
        updatedAt: note.updatedAt,
      ),
    );
  }
}
