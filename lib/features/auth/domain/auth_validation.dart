String normalizeAndValidateEmail(String email) {
  final normalized = email.trim();
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
    throw const FormatException('Nhập địa chỉ email hợp lệ.');
  }
  return normalized;
}

String validatePassword(String password) {
  if (password.length < 8) {
    throw const FormatException('Mật khẩu cần ít nhất 8 ký tự.');
  }
  return password;
}
