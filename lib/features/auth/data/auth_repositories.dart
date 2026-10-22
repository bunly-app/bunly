import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  static const user = AppUser('demo-user', '');
  @override
  AppUser get currentUser => user;
  @override
  Stream<AppUser?> get changes => Stream.value(user);
  @override
  Future<void> signIn(String email, String password) async =>
      throw UnsupportedError('Demo has no authentication');
  @override
  Future<bool> signUp(String email, String password) async =>
      throw UnsupportedError('Demo has no authentication');
  @override
  Future<void> signOut() async {}
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client);
  final SupabaseClient client;
  AppUser? _map(User? user) =>
      user == null ? null : AppUser(user.id, user.email ?? '');
  @override
  AppUser? get currentUser => _map(client.auth.currentUser);
  @override
  Stream<AppUser?> get changes =>
      client.auth.onAuthStateChange.map((event) => _map(event.session?.user));
  @override
  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> signUp(String email, String password) async {
    final result = await client.auth.signUp(email: email, password: password);
    return result.session != null;
  }

  @override
  Future<void> signOut() => client.auth.signOut();
}
