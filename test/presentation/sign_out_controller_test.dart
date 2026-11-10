import 'dart:async';

import 'package:bunly/features/auth/domain/sign_out.dart';
import 'package:bunly/features/auth/presentation/sign_out_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_test.dart' show SessionAuth;

class ControlledSignOut extends SessionAuth {
  int calls = 0;
  Completer<void>? pending;

  @override
  Future<void> signOut() async {
    calls++;
    await pending?.future;
    await super.signOut();
  }
}

void main() {
  test(
    'sign out prevents duplicate calls and permits retry after failure',
    () async {
      final auth = ControlledSignOut()..pending = Completer<void>();
      final controller = SignOutController(SignOut(auth));
      try {
        final first = controller.submit();
        expect(controller.state.isLoading, isTrue);
        expect(await controller.submit(), isFalse);
        expect(auth.calls, 1);
        auth.pending!.completeError(StateError('offline'));
        expect(await first, isFalse);
        expect(controller.state.hasError, isTrue);
        expect(auth.currentUser?.id, 'A');
        auth.pending = null;
        expect(await controller.submit(), isTrue);
        expect(auth.calls, 2);
        expect(auth.currentUser, isNull);
        expect(controller.state.hasError, isFalse);
      } finally {
        controller.dispose();
        await auth.controller.close();
      }
    },
  );

  test(
    'completion after navigation disposes controller without late state writes',
    () async {
      final auth = ControlledSignOut()..pending = Completer<void>();
      final controller = SignOutController(SignOut(auth));
      final result = controller.submit();
      controller.dispose();
      auth.pending!.complete();
      expect(await result, isTrue);
      expect(auth.currentUser, isNull);
      await auth.controller.close();
    },
  );
}
