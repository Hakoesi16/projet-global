import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // 1. Centralized base URL for all API calls
  final String _baseUrl = "https://yourbackend.com";
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- LOGIN GOOGLE ---
  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthError("User cancelled"));
        return;
      }

      final googleAuth = await googleUser.authentication;
      final response = await http.post(
        Uri.parse("$_baseUrl/google-login"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AuthAuthenticated(data));
      } else {
        emit(AuthError("Server error during Google login"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- LOGIN FACEBOOK ---
  Future<void> signInWithFacebook() async {
    try {
      emit(AuthLoading());
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        emit(AuthError("Facebook login cancelled"));
        return;
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/facebook-login"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accessToken": result.accessToken!.token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AuthAuthenticated(data));
      } else {
        emit(AuthError("Server error during Facebook login"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- LOGIN CLASSIQUE (Email/Password) ---
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/api/login"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(AuthAuthenticated(data));
      } else {
        emit(AuthError("Invalid email or password"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- INSCRIPTION ---
  Future<void> registerUser(String email, String password) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/api/register"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = jsonDecode(response.body);
        // 2. Uniform state for authentication success
        emit(AuthAuthenticated(userData));
      } else {
        emit(AuthError("Registration failed: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- PROFIL ---
  Future<void> fetchProfile(String token) async {
    try {
      emit(AuthLoading());
      final response = await http.get(
        Uri.parse("$_baseUrl/api/profile"), // Using base URL
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProfileLoaded(data));
      } else {
        emit(ProfileError("Failed to load profile"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    // 3. Added try-catch for robustness
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError("Logout failed: ${e.toString()}"));
    }
  }

  // --- EMAIL & CODE ---
  Future<void> sendEmail(String email) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/api/send-email"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        emit(EmailSentSuccess());
      } else {
        emit(AuthError("Server error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyCode(String email, String code) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/api/verify-code"), // Using base URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "code": code}),
      );
      if (response.statusCode == 200) {
        emit(CodeVerifiedSuccess());
      } else {
        emit(AuthError("Invalid code"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
