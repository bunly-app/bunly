import 'auth_repository.dart';
import 'auth_validation.dart';

class UpdatePassword {
  const UpdatePassword(this.repository);
  final AuthRepository repository;

  Future<void> call(String newPassword) async {
    validatePassword(newPassword);
    return repository.updatePassword(newPassword);
  }
}
