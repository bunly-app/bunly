import 'auth_repository.dart';

class Authenticate {
  const Authenticate(this.repository);
  final AuthRepository repository;

  Future<bool> call(
    String email,
    String password, {
    bool register = false,
  }) async {
    final normalized = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw const FormatException('Nhập địa chỉ email hợp lệ.');
    }
    if (password.length < 8) {
      throw const FormatException('Mật khẩu cần ít nhất 8 ký tự.');
    }
    if (register) return repository.signUp(normalized, password);
    await repository.signIn(normalized, password);
    return true;
  }
}
