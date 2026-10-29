import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/personal_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final name = TextEditingController();
  final goal = TextEditingController();
  final minutes = TextEditingController();
  String level = 'N5';
  bool initialized = false;
  String? message;
  @override
  void dispose() {
    name.dispose();
    goal.dispose();
    minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final save = ref.watch(learningControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ học tập')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(profileProvider),
            child: const Text('Chưa đọc được hồ sơ. Thử lại'),
          ),
        ),
        data: (p) {
          if (!initialized) {
            name.text = p.displayName;
            goal.text = p.goal;
            minutes.text = '${p.dailyMinutes}';
            level = p.level;
            initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: name,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Tên hiển thị'),
              ),
              DropdownButtonFormField<String>(
                initialValue: level,
                decoration: const InputDecoration(labelText: 'Trình độ'),
                items: ['N5', 'N4']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => level = v ?? level),
              ),
              TextField(
                controller: goal,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'Mục tiêu'),
              ),
              TextField(
                controller: minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Phút học mỗi ngày (1–1440)',
                ),
              ),
              if (save.hasError)
                Text(
                  save.error is FormatException
                      ? (save.error as FormatException).message
                      : 'Chưa lưu được hồ sơ. Hãy thử lại.',
                ),
              if (message != null) Text(message!),
              FilledButton(
                onPressed: save.isLoading
                    ? null
                    : () async {
                        final ok = await ref
                            .read(learningControllerProvider.notifier)
                            .perform(
                              (useCase) => useCase.saveProfile(
                                UserProfile(
                                  displayName: name.text,
                                  level: level,
                                  goal: goal.text,
                                  dailyMinutes: int.tryParse(minutes.text) ?? 0,
                                ),
                              ),
                            );
                        if (mounted && ok) {
                          setState(() => message = 'Đã lưu trên thiết bị.');
                        }
                      },
                child: Text(save.isLoading ? 'Đang lưu…' : 'Lưu hồ sơ'),
              ),
            ],
          );
        },
      ),
    );
  }
}
