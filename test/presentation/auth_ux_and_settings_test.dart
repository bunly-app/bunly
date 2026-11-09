import 'dart:async';

import 'package:bunly/app/bunly_app.dart';
import 'package:bunly/app/config.dart';
import 'package:bunly/app/providers.dart';
import 'package:bunly/features/auth/domain/auth_failure.dart';
import 'package:bunly/features/auth/domain/auth_repository.dart';
import 'package:bunly/features/auth/presentation/email_verification_screen.dart';
import 'package:bunly/features/auth/presentation/forgot_password_screen.dart';
import 'package:bunly/features/auth/presentation/reset_password_screen.dart';
import 'package:bunly/features/learning/presentation/profile_screen.dart';
import 'package:bunly/features/settings/domain/app_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_shell_test.dart' show closeLearning;
import 'app_test.dart' show WidgetGrammar;
import 'personal_test.dart' show PersonalFake;
import '../support/fake_practice_storage.dart'
    show FakePracticeStorageRepository;

class _ConnectedFakeAuth implements AuthRepository {
  _ConnectedFakeAuth({this.initialUser, this.initialRecovering = false})
    : _user = initialUser,
      _recovering = initialRecovering;

  final AppUser? initialUser;
  final bool initialRecovering;

  AppUser? _user;
  bool _recovering;
  final _changes = StreamController<AppUser?>.broadcast();
  final _recovery = StreamController<bool>.broadcast();

  String? lastSignInEmail;
  String? lastSignUpEmail;
  String? lastResendEmail;
  String? lastResetEmail;
  String? lastUpdatedPassword;
  bool failWithUnconfirmedOnSignIn = false;
  bool signUpHasSession = false;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> get changes => _changes.stream;

  @override
  Stream<bool> get recoveryEvents async* {
    yield _recovering;
    yield* _recovery.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    lastSignInEmail = email;
    if (failWithUnconfirmedOnSignIn) {
      throw const AuthFailure(
        AuthFailureKind.emailNotConfirmed,
        'Email này chưa được xác nhận.',
      );
    }
    _user = AppUser('u1', email);
    _changes.add(_user);
  }

  @override
  Future<bool> signUp(String email, String password) async {
    lastSignUpEmail = email;
    if (signUpHasSession) {
      _user = AppUser('u1', email);
      _changes.add(_user);
      return true;
    }
    return false;
  }

  @override
  Future<void> resendConfirmation(String email) async {
    lastResendEmail = email;
  }

  @override
  Future<void> resetPassword(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    lastUpdatedPassword = newPassword;
  }

  @override
  Future<void> completeRecovery() async {
    _recovering = false;
    if (!_recovery.isClosed) _recovery.add(false);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _recovering = false;
    if (!_changes.isClosed) _changes.add(null);
    if (!_recovery.isClosed) _recovery.add(false);
  }

  Future<void> close() async {
    await _changes.close();
    await _recovery.close();
  }
}

class _MemorySettings implements AppSettingsRepository {
  AppThemePreference saved = AppThemePreference.system;

  @override
  Future<AppThemePreference> loadThemePreference() async => saved;

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    saved = preference;
  }
}

void main() {
  testWidgets(
    'S01 -> S02 -> S03 confirmation flow resends and preserves email returning to S01',
    (tester) async {
      final auth = _ConnectedFakeAuth();
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(() async {
        await auth.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(
              const AppConfig(
                connected: true,
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon-key',
              ),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Tạo tài khoản mới'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Tạo tài khoản mới'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'newuser@bunly.edu.vn',
      );
      await tester.enterText(find.byType(TextField).at(1), 'Bunly2026!secure');
      await tester.enterText(find.byType(TextField).at(2), 'Bunly2026!secure');

      await tester.scrollUntilVisible(
        find.text('Đăng ký'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();

      expect(auth.lastSignUpEmail, 'newuser@bunly.edu.vn');
      expect(find.byType(EmailVerificationScreen), findsOneWidget);
      expect(find.text('Kiểm tra hộp thư của bạn'), findsOneWidget);
      expect(find.text('newuser@bunly.edu.vn'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Gửi lại email xác nhận'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Gửi lại email xác nhận'));
      await tester.pumpAndSettle();
      expect(auth.lastResendEmail, 'newuser@bunly.edu.vn');
      expect(find.textContaining('đã gửi lại liên kết'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Đã xác nhận — Đến đăng nhập'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Đã xác nhận — Đến đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập'), findsWidgets);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        'newuser@bunly.edu.vn',
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'S01 unconfirmed login offers jump to S03 and S04a sends neutral reset message',
    (tester) async {
      final auth = _ConnectedFakeAuth()..failWithUnconfirmedOnSignIn = true;
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      addTearDown(() async {
        await auth.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(
              const AppConfig(
                connected: true,
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon-key',
              ),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(0),
        'pending@bunly.edu.vn',
      );
      await tester.enterText(find.byType(TextField).at(1), 'Bunly2026!secure');
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Đăng nhập'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Mở hướng dẫn xác nhận email'), findsOneWidget);
      await tester.tap(find.text('Mở hướng dẫn xác nhận email'));
      await tester.pumpAndSettle();
      expect(find.byType(EmailVerificationScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Quên mật khẩu?'),
        -150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        'pending@bunly.edu.vn',
      );

      await tester.scrollUntilVisible(
        find.text('Gửi liên kết đặt lại mật khẩu'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Gửi liên kết đặt lại mật khẩu'));
      await tester.pumpAndSettle();

      expect(auth.lastResetEmail, 'pending@bunly.edu.vn');
      expect(
        find.textContaining('Nếu email này đã đăng ký trong hệ thống'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'password recovery gates AppShell until S04b/S04c completes and theme switcher persists',
    (tester) async {
      final auth = _ConnectedFakeAuth(
        initialUser: const AppUser('u1', 'hocvien@bunly.edu.vn'),
        initialRecovering: true,
      );
      final learning = PersonalFake();
      final practiceStorage = FakePracticeStorageRepository();
      final settings = _MemorySettings();
      addTearDown(() async {
        await auth.close();
        await closeLearning(learning);
        await practiceStorage.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configProvider.overrideWithValue(
              const AppConfig(
                connected: true,
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon-key',
              ),
            ),
            authRepositoryProvider.overrideWithValue(auth),
            grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
            learningRepositoryProvider.overrideWithValue(learning),
            practiceStorageRepositoryProvider.overrideWithValue(
              practiceStorage,
            ),
            learningSyncProvider.overrideWithValue(null),
            pendingSyncProvider.overrideWith((ref) => Stream.value(0)),
            appSettingsRepositoryProvider.overrideWithValue(settings),
          ],
          child: const BunlyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Must gate AppShell on S04b recovery screen.
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Tạo mật khẩu mới'), findsOneWidget);
      expect(find.text('Hôm nay'), findsNothing);

      await tester.enterText(find.byType(TextField).at(0), 'NewPass2026!');
      await tester.enterText(find.byType(TextField).at(1), 'NewPass2026!');
      await tester.scrollUntilVisible(
        find.text('Lưu mật khẩu mới'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Lưu mật khẩu mới'));
      await tester.pumpAndSettle();

      expect(auth.lastUpdatedPassword, 'NewPass2026!');
      expect(find.text('Mật khẩu đã được cập nhật'), findsOneWidget);

      await tester.tap(find.text('Tiếp tục vào Bunly'));
      await tester.pumpAndSettle();

      // Now AppShell opens and user can open Hồ sơ & Cài đặt to switch ThemeMode.
      expect(find.text('Bunly'), findsOneWidget);
      await tester.tap(find.byTooltip('Hồ sơ học tập'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('theme-chip-dark')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('theme-chip-dark')));
      await tester.pumpAndSettle();

      expect(settings.saved, AppThemePreference.dark);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );

      await tester.tap(find.byKey(const ValueKey('theme-chip-light')));
      await tester.pumpAndSettle();
      expect(settings.saved, AppThemePreference.light);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'responsive sweep on 320x640 @ 2.0 and 1024x768 @ 1.4 passes for S01/S03/S04/Profile',
    (tester) async {
      final sizes = <(Size, double)>[
        (const Size(320, 640), 2.0),
        (const Size(1024, 768), 1.4),
      ];

      for (final (size, scale) in sizes) {
        tester.view.physicalSize = size * tester.view.devicePixelRatio;
        final learning = PersonalFake();
        final practiceStorage = FakePracticeStorageRepository();
        final auth = _ConnectedFakeAuth();
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          await auth.close();
          await closeLearning(learning);
          await practiceStorage.dispose();
        });

        for (final screen in <Widget>[
          const EmailVerificationScreen(
            email: 'hocvien@bunly.edu.vn',
            previewMode: true,
          ),
          const ForgotPasswordScreen(
            initialEmail: 'hocvien@bunly.edu.vn',
            previewMode: true,
          ),
          const ResetPasswordScreen(isRecoveryFlow: false, previewMode: true),
          const ProfileScreen(),
        ]) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authRepositoryProvider.overrideWithValue(auth),
                grammarRepositoryProvider.overrideWithValue(WidgetGrammar()),
                learningRepositoryProvider.overrideWithValue(learning),
                practiceStorageRepositoryProvider.overrideWithValue(
                  practiceStorage,
                ),
              ],
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: screen,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Overflow/error at $size scale $scale on $screen',
          );
        }
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
