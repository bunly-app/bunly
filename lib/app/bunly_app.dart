import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/grammar/presentation/grammar_screen.dart';
import 'providers.dart';

class BunlyApp extends ConsumerWidget {
  const BunlyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(userProvider);
    final user = session.valueOrNull;
    return MaterialApp(
      // Replacing the navigator removes private detail routes on account changes.
      key: ValueKey(
        '${ref.watch(configProvider).namespace}:${user?.id ?? 'signed-out'}',
      ),
      title: 'Bunly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6840)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6840),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: session.when(
        data: (user) =>
            user == null ? const AuthScreen() : const GrammarScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const Scaffold(
          body: Center(
            child: Text('Không đọc được phiên đăng nhập. Hãy mở lại ứng dụng.'),
          ),
        ),
      ),
    );
  }
}
