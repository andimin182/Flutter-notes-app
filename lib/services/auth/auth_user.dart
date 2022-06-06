import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;

  const AuthUser({
    required this.isEmailVerified,
    required this.email,
  });

// make a copy of the Firebase user in our AuthUser so that we are not exposing all the FB user
// properties to our interface
  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email,
      );
}
