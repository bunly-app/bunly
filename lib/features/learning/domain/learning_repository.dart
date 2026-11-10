import 'note.dart';

abstract interface class LearningRepository {
  Stream<List<Note>> watchNotes(String grammarId);
  Stream<List<Note>> watchAllNotes();
  Future<void> saveNote(Note note);
}
