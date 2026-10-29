import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../learning/domain/note.dart';
import '../domain/grammar_point.dart';
import '../../learning/presentation/learning_controls.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  const GrammarDetailScreen({super.key, required this.point});
  final GrammarPoint point;
  @override
  ConsumerState<GrammarDetailScreen> createState() =>
      _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  final content = TextEditingController();
  String? editingId;
  String? noteMessage;
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final save = ref.watch(noteControllerProvider);
    final mutation = ref.watch(learningControllerProvider);
    final notes = ref.watch(notesProvider(point.id));
    return Scaffold(
      appBar: AppBar(title: Text(point.pattern)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${point.level} · ${point.meaning}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(point.formula, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(point.usage),
          for (final example in point.examples)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.japanese,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(example.vietnamese),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          LearningControls(grammarId: point.id),
          const SizedBox(height: 20),
          Text(
            'Ghi chú của bạn',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Ghi chú lưu ngay trên thiết bị. Ở chế độ kết nối, dùng Đồng bộ tại kho ngữ pháp để gửi lên tài khoản.',
          ),
          TextField(
            enabled: !save.isLoading,
            controller: content,
            minLines: 2,
            maxLines: 5,
            maxLength: 2000,
            decoration: const InputDecoration(labelText: 'Nội dung ghi chú'),
          ),
          if (save.hasError)
            Text(
              save.error is FormatException
                  ? (save.error as FormatException).message
                  : 'Chưa lưu được ghi chú. Hãy thử lại.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          FilledButton(
            onPressed: save.isLoading
                ? null
                : () async {
                    final ok = await ref
                        .read(noteControllerProvider.notifier)
                        .save(
                          Note(
                            id: editingId ?? const Uuid().v4(),
                            grammarId: point.id,
                            content: content.text,
                            updatedAt: DateTime.now().toUtc(),
                          ),
                        );
                    if (ok && context.mounted) {
                      content.clear();
                      setState(() {
                        editingId = null;
                        noteMessage = 'Đã lưu trên thiết bị.';
                      });
                    }
                  },
            child: Text(
              save.isLoading
                  ? 'Đang lưu…'
                  : editingId == null
                  ? 'Lưu ghi chú'
                  : 'Lưu chỉnh sửa',
            ),
          ),
          if (noteMessage != null) Text(noteMessage!),
          if (editingId != null)
            TextButton(
              onPressed: save.isLoading
                  ? null
                  : () => setState(() {
                      editingId = null;
                      content.clear();
                    }),
              child: const Text('Hủy chỉnh sửa'),
            ),
          notes.when(
            data: (items) => Column(
              children: items
                  .map(
                    (note) => ListTile(
                      title: Text(note.content),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Sửa ghi chú',
                            icon: const Icon(Icons.edit),
                            onPressed: save.isLoading || mutation.isLoading
                                ? null
                                : () => setState(() {
                                    editingId = note.id;
                                    content.text = note.content;
                                  }),
                          ),
                          IconButton(
                            tooltip: 'Xóa ghi chú',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: save.isLoading || mutation.isLoading
                                ? null
                                : () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Xóa ghi chú?'),
                                        content: const Text(
                                          'Ghi chú sẽ bị xóa khỏi danh sách của bạn.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Hủy'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true && context.mounted) {
                                      final deleted = await ref
                                          .read(
                                            learningControllerProvider.notifier,
                                          )
                                          .perform(
                                            (u) => u.deleteNote(note.id),
                                          );
                                      if (mounted &&
                                          deleted &&
                                          editingId == note.id) {
                                        setState(() {
                                          editingId = null;
                                          content.clear();
                                        });
                                      }
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Chưa đọc được ghi chú.'),
          ),
        ],
      ),
    );
  }
}
