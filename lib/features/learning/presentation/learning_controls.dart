import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/personal_repository.dart';

class LearningControls extends ConsumerWidget {
  const LearningControls({super.key, required this.grammarId});
  final String grammarId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(learningSummaryProvider);
    final action = ref.watch(learningControllerProvider);
    return summary.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Chưa đọc được tiến độ.'),
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: action.isLoading
                ? null
                : () => ref
                      .read(learningControllerProvider.notifier)
                      .perform(
                        (u) => u.setSaved(
                          grammarId,
                          !data.saved.contains(grammarId),
                        ),
                      ),
            icon: Icon(
              data.saved.contains(grammarId)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            label: Text(
              data.saved.contains(grammarId) ? 'Bỏ lưu mẫu' : 'Lưu mẫu',
            ),
          ),
          DropdownButtonFormField<LearningStatus>(
            key: ValueKey((
              data.statusOf(grammarId),
              action.isLoading,
              action.hasError,
            )),
            initialValue: data.statusOf(grammarId),
            decoration: const InputDecoration(labelText: 'Trạng thái học'),
            items: LearningStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: action.isLoading
                ? null
                : (status) {
                    if (status != null) {
                      ref
                          .read(learningControllerProvider.notifier)
                          .perform((u) => u.setStatus(grammarId, status));
                    }
                  },
          ),
          if (action.hasError)
            const Text('Chưa lưu được thay đổi. Hãy thử lại.'),
        ],
      ),
    );
  }
}
