enum AuthFailureKind {
  invalidCredentials,
  emailNotConfirmed,
  userAlreadyExists,
  rateLimited,
  networkOrUnavailable,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, this.message);

  final AuthFailureKind kind;
  final String message;

  @override
  String toString() => message;
}
