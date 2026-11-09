import 'auth_repository.dart';
import 'auth_validation.dart';

class Authenticate {
  const Authenticate(this.repository);
  final AuthRepository repository;

  Future<bool> call(
    String email,
    String password, {
    bool register = false,
  }) async {
    final normalized = normalizeAndValidateEmail(email);
    validatePassword(password);
    if (register) return repository.signUp(normalized, password);
    await repository.signIn(normalized, password);
    return true;
  }
}
