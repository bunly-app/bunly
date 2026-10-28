import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/bunly_app.dart';
import 'app/config.dart';
import 'app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = AppConfig.fromEnvironment();
    if (config.connected &&
        kReleaseMode &&
        !config.supabaseUrl.startsWith('https://')) {
      throw ArgumentError('Release connections require HTTPS');
    }
    if (config.connected) {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
    }
    runApp(
      ProviderScope(
        overrides: [configProvider.overrideWithValue(config)],
        child: const BunlyApp(),
      ),
    );
  } catch (_) {
    // Never display configuration values or credentials in startup errors.
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Không thể khởi động. Kiểm tra cấu hình và hướng dẫn thiết lập Bunly.',
            ),
          ),
        ),
      ),
    );
  }
}
