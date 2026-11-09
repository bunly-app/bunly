import 'auth_repository.dart';
import 'auth_validation.dart';

class ResendConfirmation {
  const ResendConfirmation(this.repository);
  final AuthRepository repository;

  Future<void> call(String email) async {
    final normalized = normalizeAndValidateEmail(email);
    return repository.resendConfirmation(normalized);
  }
}
