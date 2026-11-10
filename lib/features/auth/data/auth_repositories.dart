import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  static const user = AppUser('demo-user', '');

  @override
  AppUser get currentUser => user;

  @override
  Stream<AppUser?> get changes => Stream.value(user);

  @override
  Stream<bool> get recoveryEvents => Stream.value(false);

  @override
  Future<void> signIn(String email, String password) async =>
      throw UnsupportedError('Offline mode has no authentication');

  @override
  Future<bool> signUp(String email, String password) async =>
      throw UnsupportedError('Offline mode has no authentication');

  @override
  Future<void> resendConfirmation(String email) async =>
      throw UnsupportedError('Offline mode has no authentication');

  @override
  Future<void> resetPassword(String email) async =>
      throw UnsupportedError('Offline mode has no authentication');

  @override
  Future<void> updatePassword(String newPassword) async =>
      throw UnsupportedError('Offline mode has no authentication');

  @override
  Future<void> completeRecovery() async {}

  @override
  Future<void> signOut() async {}
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client) {
    _subscription = client.auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _recovering = true;
          _emitRecovery();
        } else if (state.event == AuthChangeEvent.signedOut) {
          _recovering = false;
          _emitRecovery();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        // Ignore transient network refresh errors; genuine sign-out emits AuthChangeEvent.signedOut.
      },
    );
  }

  static const authRedirectUrl = 'bunly://auth-callback';

  final SupabaseClient client;
  final StreamController<bool> _recoveryController =
      StreamController<bool>.broadcast();
  late final StreamSubscription<AuthState> _subscription;
  bool _recovering = false;

  void _emitRecovery() {
    if (!_recoveryController.isClosed) {
      _recoveryController.add(_recovering);
    }
  }

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_recoveryController.close());
  }

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(user.id, user.email ?? '');

  AuthFailure _translate(Object error) {
    if (error is AuthException) {
      final code = (error.code ?? '').toLowerCase();
      final msg = error.message.toLowerCase();
      if (code == 'email_not_confirmed' ||
          msg.contains('email not confirmed')) {
        return const AuthFailure(
          AuthFailureKind.emailNotConfirmed,
          'Email này chưa được xác nhận. Hãy mở liên kết trong hộp thư hoặc gửi lại email xác nhận.',
        );
      }
      if (code == 'invalid_credentials' ||
          msg.contains('invalid login credentials')) {
        return const AuthFailure(
          AuthFailureKind.invalidCredentials,
          'Email hoặc mật khẩu chưa đúng. Email được giữ nguyên để bạn chỉnh sửa.',
        );
      }
      if (code == 'user_already_exists' ||
          msg.contains('already registered') ||
          msg.contains('already exists')) {
        return const AuthFailure(
          AuthFailureKind.userAlreadyExists,
          'Email này đã được đăng ký. Hãy đăng nhập hoặc đặt lại mật khẩu.',
        );
      }
      if (code == 'over_email_send_rate_limit' ||
          error.statusCode == '429' ||
          msg.contains('rate limit')) {
        return const AuthFailure(
          AuthFailureKind.rateLimited,
          'Bạn thao tác quá nhanh. Vui lòng đợi một lát rồi thử lại.',
        );
      }
      return const AuthFailure(
        AuthFailureKind.unknown,
        'Không thể hoàn tất yêu cầu xác thực lúc này. Hãy thử lại.',
      );
    }
    if (error is SocketException || error is TimeoutException) {
      return const AuthFailure(
        AuthFailureKind.networkOrUnavailable,
        'Chưa kết nối được máy chủ xác thực. Kiểm tra mạng và thử lại.',
      );
    }
    return const AuthFailure(
      AuthFailureKind.unknown,
      'Không thể xác thực lúc này. Kiểm tra tài khoản và kết nối mạng.',
    );
  }

  @override
  AppUser? get currentUser => _map(client.auth.currentUser);

  @override
  Stream<AppUser?> get changes => mapAuthStateChanges(
    client.auth.onAuthStateChange,
    () => client.auth.currentUser,
  );

  @visibleForTesting
  static Stream<AppUser?> mapAuthStateChanges(
    Stream<AuthState> source,
    User? Function() readCurrentUser,
  ) {
    return source.transform(
      StreamTransformer<AuthState, AppUser?>.fromHandlers(
        handleData: (event, sink) {
          final user = event.session?.user;
          sink.add(user == null ? null : AppUser(user.id, user.email ?? ''));
        },
        handleError: (error, stackTrace, sink) {
          if (error is AuthRetryableFetchException ||
              error is SocketException ||
              error is TimeoutException ||
              error is HttpException) {
            final cached = readCurrentUser();
            sink.add(
              cached == null ? null : AppUser(cached.id, cached.email ?? ''),
            );
            return;
          }
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  @override
  Stream<bool> get recoveryEvents async* {
    yield _recovering;
    yield* _recoveryController.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<bool> signUp(String email, String password) async {
    try {
      final result = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: authRedirectUrl,
      );
      return result.session != null;
    } catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: authRedirectUrl,
      );
    } catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: authRedirectUrl,
      );
    } catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<void> completeRecovery() async {
    _recovering = false;
    _emitRecovery();
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      _recovering = false;
      _emitRecovery();
    } catch (error) {
      throw _translate(error);
    }
  }
}
