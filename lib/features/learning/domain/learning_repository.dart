import 'note.dart';

abstract interface class LearningRepository {
  Stream<List<Note>> watchNotes(String grammarId);
  Future<void> saveNote(Note note);
}
