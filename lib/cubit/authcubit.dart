import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

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
        Uri.parse("https://backend.com"),
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
        Uri.parse("https://backend.com"),
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
        Uri.parse("https://backend.com"),
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
        Uri.parse("https://backend.com"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = jsonDecode(response.body);
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
    // For testing purposes, emitting dummy data
    emit(ProfileLoaded({
      "name": "Captain Hako",
      "email": "hako@gmail.com",
      "boatName": "Sea Explorer",
      "registration": "MAR-9999",
      "homePort": "Oran",
      "licenseExpiry": "2026",
    }));
  }

  // --- HOME DATA ---
  Future<void> fetchHomeData(String token) async {
    try {
      emit(AuthLoading());
      // Simulation d'un appel API
      await Future.delayed(const Duration(seconds: 1));
      
      emit(HomeDataLoaded({
        "userName": "Capt. Hako",
        "earnings": "12,450.00 DA",
        "earningsTrend": "8.4%",
        "weight": "4,250 kg",
        "weightTrend": "5.2%",
        "pendingBatches": 24,
        "approvedBatches": 85,
        "rejectedBatches": 12,
        "expiredBatches": 7,
        "marketItem": {
          "name": "Sardine",
          "grade": "Premium Grade",
          "demand": "Rising Demand",
          "price": "320.50 DA / kg",
          "tag": "High Demand"
        }
      }));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- UPDATE PROFIL ---
  Future<void> updateProfile({
    required String token,
    required String name,
    required String phone,
    required String homePort,
    required String boatName,
  }) async {
    try {
      emit(AuthLoading());
      final response = await http.put(
        Uri.parse("https://backend.com"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "homePort": homePort,
          "boatName": boatName,
        }),
      );

      if (response.statusCode == 200) {
        emit(ProfileUpdatedSuccess());
      } else {
        emit(ProfileError("Update failed"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
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
        Uri.parse("https://backend.com"),
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
        Uri.parse("https://backend.com"),
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
