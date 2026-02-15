import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final GoogleSignInAccount user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthSuccessFacebook extends AuthState {
  final Map<String, dynamic> userData;
  AuthSuccessFacebook(this.userData);
}

class EmailSentSuccess extends AuthState {}

class CodeVerifiedSuccess extends AuthState {}

class PasswordSentSuccess extends AuthState {}