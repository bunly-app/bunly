class AppConfig {
  const AppConfig({
    this.connected = false,
    this.supabaseUrl = '',
    this.supabaseAnonKey = '',
  });

  factory AppConfig.fromEnvironment() => AppConfig.parse(
    mode: const String.fromEnvironment('APP_MODE', defaultValue: 'demo'),
    url: const String.fromEnvironment('SUPABASE_URL'),
    key: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  factory AppConfig.parse({
    required String mode,
    String url = '',
    String key = '',
  }) {
    if (mode != 'demo' && mode != 'connected') {
      throw ArgumentError('APP_MODE must be demo or connected');
    }
    if (mode == 'connected') {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          key.isEmpty ||
          key.startsWith('REPLACE_')) {
        throw ArgumentError('Connected mode requires a URL and client key');
      }
    }
    return AppConfig(
      connected: mode == 'connected',
      supabaseUrl: url,
      supabaseAnonKey: key,
    );
  }

  final bool connected;
  final String supabaseUrl;
  final String supabaseAnonKey;
  String get namespace => connected ? 'supabase:$supabaseUrl' : 'demo';
}
