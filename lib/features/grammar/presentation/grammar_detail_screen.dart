import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/providers.dart';
import '../../learning/domain/note.dart';
import '../domain/grammar_point.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  const GrammarDetailScreen({super.key, required this.point});
  final GrammarPoint point;
  @override
  ConsumerState<GrammarDetailScreen> createState() =>
      _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  final content = TextEditingController();
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final save = ref.watch(noteControllerProvider);
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
          Text(
            'Ghi chú của bạn',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Ghi chú hiện được lưu trên thiết bị. Chưa hỗ trợ đồng bộ lên tài khoản.',
          ),
          TextField(
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
                            id: const Uuid().v4(),
                            grammarId: point.id,
                            content: content.text,
                            updatedAt: DateTime.now().toUtc(),
                          ),
                        );
                    if (ok && context.mounted) {
                      content.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã lưu trên thiết bị.')),
                      );
                    }
                  },
            child: Text(save.isLoading ? 'Đang lưu…' : 'Lưu ghi chú'),
          ),
          notes.when(
            data: (items) => Column(
              children: items
                  .map((note) => ListTile(title: Text(note.content)))
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
