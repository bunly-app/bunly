class AppUser {
  const AppUser(this.id, this.email);
  final String id;
  final String email;
}

abstract interface class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> get changes;
  Stream<bool> get recoveryEvents;
  Future<void> signIn(String email, String password);

  /// Returns false when email confirmation is required before a session exists.
  Future<bool> signUp(String email, String password);
  Future<void> resendConfirmation(String email);
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> completeRecovery();
  Future<void> signOut();
}
