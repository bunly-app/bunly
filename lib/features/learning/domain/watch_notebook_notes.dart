import 'learning_repository.dart';
import 'note.dart';

class WatchNotebookNotes {
  const WatchNotebookNotes(this.repository);
  final LearningRepository repository;

  Stream<List<Note>> call() => repository.watchAllNotes();
}
