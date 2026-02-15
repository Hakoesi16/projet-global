import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthError("User cancelled"));
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      // 🔥 envoyer au backend
      final response = await http.post(
        Uri.parse("https://yourbackend.com/google-login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        emit(AuthSuccess(googleUser));
      } else {
        emit(AuthError("Server error"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  //sign in avec facebook account
  Future<void> signInWithFacebook() async {
    try {
      emit(AuthLoading());

      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken?.token;

        // 🔥 envoyer au backend
        final response = await http.post(
          Uri.parse("https://yourbackend.com/facebook-login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"accessToken": accessToken}),
        );
        if (response.statusCode == 200) {
          // Récupérer les infos utilisateur
          final userData = await FacebookAuth.instance.getUserData();
          emit(AuthSuccessFacebook(userData)); // Nouveau state pour FB
        } else {
          emit(AuthError("Server error"));
        }
      } else if (result.status == LoginStatus.cancelled) {
        emit(AuthError("User cancelled"));
      } else {
        emit(AuthError(result.message ?? "Facebook login failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> sendEmail(String email) async {
    try {
      emit(AuthLoading());

      final response = await http.post(
        Uri.parse("https://yourbackend.com/api/send-email"), // Remplacez par votre URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        emit(EmailSentSuccess());
      } else {
        emit(AuthError("Erreur du serveur : ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> verifyCode(String email, String code) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("https://yourbackend.com/api/verify-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );

      if (response.statusCode == 200) {
        emit(CodeVerifiedSuccess());
      } else {
        emit(AuthError("Code incorrect"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> sendpassword(String password) async {//sendemail->sendpassword
    try {
      emit(AuthLoading());

      final response = await http.post(
        Uri.parse("https://yourbackend.com/api/send-email"), // Remplacez par votre URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"password": password}),
      );

      if (response.statusCode == 200) {
        emit(PasswordSentSuccess());
      } else {
        emit(AuthError("Erreur du serveur : ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> registerUser(String email, String password) async {
    try {
      emit(AuthLoading());

      final response = await http.post(
        Uri.parse("https://yourbackend.com/api/register"), // Mettez votre URL réelle
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(PasswordSentSuccess());
      } else {
        emit(AuthError("Erreur lors de l'inscription : ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
