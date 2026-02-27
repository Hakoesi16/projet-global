import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userData;
  AuthAuthenticated(this.userData);

  @override
  List<Object?> get props => [userData];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailSentSuccess extends AuthState {}

class CodeVerifiedSuccess extends AuthState {}

class ProfileLoaded extends AuthState {
  final Map<String, dynamic> user;
  ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdatedSuccess extends AuthState {} // État ajouté ici

class ProfileError extends AuthState {
  final String message;
  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
