import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bunly_brand.dart';
import '../../../app/providers.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/presentation/reset_password_screen.dart';
import '../../settings/domain/app_settings_repository.dart';
import '../domain/personal_repository.dart';
import 'learning_widgets.dart';

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
    final connected = ref.watch(configProvider).connected;
    final user = ref.watch(userProvider).valueOrNull;
    final signOut = ref.watch(signOutControllerProvider);
    final themePref = ref.watch(themeControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & Cài đặt')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(profileProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Chưa đọc được hồ sơ. Thử lại'),
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                children: [
                  LearningSection(
                    children: [
                      TextField(
                        controller: name,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Tên hiển thị',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: level,
                        decoration: const InputDecoration(
                          labelText: 'Trình độ',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: ['N5', 'N4']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => level = v ?? level),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: goal,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Mục tiêu',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: minutes,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Phút học mỗi ngày (1–1440)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                      ),
                      if (save.hasError) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            save.error is FormatException
                                ? (save.error as FormatException).message
                                : 'Chưa lưu được hồ sơ. Hãy thử lại.',
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ),
                      ],
                      if (message != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message!,
                            style: TextStyle(
                              color: colors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: save.isLoading
                            ? null
                            : () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                final ok = await ref
                                    .read(learningControllerProvider.notifier)
                                    .perform(
                                      (useCase) => useCase.saveProfile(
                                        UserProfile(
                                          displayName: name.text,
                                          level: level,
                                          goal: goal.text,
                                          dailyMinutes:
                                              int.tryParse(minutes.text) ?? 0,
                                        ),
                                      ),
                                    );
                                if (mounted && ok) {
                                  setState(
                                    () => message = 'Đã lưu trên thiết bị.',
                                  );
                                }
                              },
                        child: Text(save.isLoading ? 'Đang lưu…' : 'Lưu hồ sơ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LearningSection(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cài đặt giao diện',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chọn chế độ hiển thị Sáng, Tối hoặc tự động theo thiết bị.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            key: const ValueKey('theme-chip-system'),
                            avatar: const Icon(
                              Icons.brightness_auto_outlined,
                              size: 16,
                            ),
                            label: const Text('Theo hệ thống'),
                            selected: themePref == AppThemePreference.system,
                            onSelected: (_) => ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.system),
                          ),
                          ChoiceChip(
                            key: const ValueKey('theme-chip-light'),
                            avatar: const Icon(
                              Icons.light_mode_outlined,
                              size: 16,
                            ),
                            label: const Text('Sáng'),
                            selected: themePref == AppThemePreference.light,
                            onSelected: (_) => ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.light),
                          ),
                          ChoiceChip(
                            key: const ValueKey('theme-chip-dark'),
                            avatar: const Icon(
                              Icons.dark_mode_outlined,
                              size: 16,
                            ),
                            label: const Text('Tối'),
                            selected: themePref == AppThemePreference.dark,
                            onSelected: (_) => ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.dark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LearningSection(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BunlyLogoMark(size: 44, borderRadius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      connected
                                          ? 'Tài khoản & Đồng bộ'
                                          : 'Tài khoản cục bộ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: connected
                                            ? colors.secondaryContainer
                                            : colors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        connected
                                            ? 'Đã kết nối máy chủ'
                                            : 'Chế độ ngoại tuyến',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: connected
                                                  ? colors.onSecondaryContainer
                                                  : colors.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  connected
                                      ? (user?.email.isNotEmpty == true
                                            ? user!.email
                                            : 'Phiên đăng nhập đang hoạt động')
                                      : 'Dữ liệu, ghi chú và giao diện được lưu trực tiếp trên thiết bị.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (connected)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ResetPasswordScreen(
                                    isRecoveryFlow: false,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.lock_reset_outlined),
                              label: const Text('Đổi mật khẩu'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: signOut.isLoading
                                  ? null
                                  : () async {
                                      final ok = await ref
                                          .read(
                                            signOutControllerProvider.notifier,
                                          )
                                          .submit();
                                      if (!context.mounted) return;
                                      if (ok) {
                                        Navigator.of(
                                          context,
                                        ).popUntil((route) => route.isFirst);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Chưa thể đăng xuất. Hãy thử lại.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.logout),
                              label: Text(
                                signOut.isLoading
                                    ? 'Đang đăng xuất…'
                                    : 'Đăng xuất',
                              ),
                            ),
                          ],
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const AuthScreen(previewMode: true),
                            ),
                          ),
                          icon: const Icon(Icons.login_outlined),
                          label: const Text(
                            'Mở giao diện Đăng nhập & Xác thực',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LearningNotice(
                    title: 'Lộ trình & thói quen học',
                    icon: Icons.person_outline,
                    message:
                        'Cập nhật trình độ JLPT mục tiêu và thời lượng học mỗi ngày. Dữ liệu lưu trực tiếp trên thiết bị.',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
