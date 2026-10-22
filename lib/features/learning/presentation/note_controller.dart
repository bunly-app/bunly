import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../domain/save_note.dart';

class NoteController extends StateNotifier<AsyncValue<void>> {
  NoteController(this.saveNote) : super(const AsyncData(null));
  final SaveNote saveNote;

  Future<bool> save(Note note) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => saveNote(note));
    if (!mounted) return false;
    state = result;
    return !result.hasError;
  }
}
