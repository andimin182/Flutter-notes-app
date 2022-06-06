import 'package:notes2/services/auth/auth_user.dart';

abstract class AuthProvider {
  // Initialize the provider
  Future<void> initialize();
  // known as well as Interface == Abstract
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
}
