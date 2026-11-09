import 'auth_repository.dart';
import 'auth_validation.dart';

class RequestPasswordReset {
  const RequestPasswordReset(this.repository);
  final AuthRepository repository;

  Future<void> call(String email) async {
    final normalized = normalizeAndValidateEmail(email);
    return repository.resetPassword(normalized);
  }
}
