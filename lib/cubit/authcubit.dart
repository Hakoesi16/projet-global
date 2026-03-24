import 'dart:convert';
import 'dart:io';
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
        Uri.parse("$_baseUrl/google-login"),
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
        Uri.parse("$_baseUrl/facebook-login"),
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
        Uri.parse("$_baseUrl/api/login"),
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
        Uri.parse("$_baseUrl/api/register"),
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
    emit(ProfileLoaded({
      "name": "Captain Ahmed",
      "email": "ahmed@mail.com",
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
      await Future.delayed(const Duration(seconds: 1));
      emit(HomeDataLoaded({
        "userName": "Capt. Ahmed",
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
// --- VET INSPECTION DATA ---


//   Future<void> fetchInspectionDetails(String batchId, String token) async {
//     try {
//       emit(AuthLoading());
//
//       final response = await http.get(
//         Uri.parse("https://yourbackend.com/api/inspection/$batchId"),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token", // 🔐 important
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         emit(InspectionDataLoaded({
//           "status": data["status"],
//           "batchId": data["batchId"],
//           "fisherName": data["fisherName"],
//           "fishType": data["fishType"],
//           "expiryDate": data["expiryDate"],
//           "timeLeft": data["timeLeft"],
//         }));
//       } else {
//         emit(AuthError("Failed to load inspection data"));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

  Future<void> sendRejectionReason({
    required String batchId,
    required String reason,
    required String token,
  }) async {
    try {    emit(AuthLoading());
    final response = await http.post(
      Uri.parse("$_baseUrl/api/reject-batch"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "batchId": batchId,
        "reason": reason,
      }),
    );

    if (response.statusCode == 200) {
      // Vous pouvez émettre un état de succès ici
      emit(InspectionDataLoaded(jsonDecode(response.body)));
    } else {
      emit(AuthError("Failed to send rejection"));
    }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  // --- VET INSPECTION DATA ---par simulation
  Future<void> fetchInspectionDetails(String batchId, String token) async {
    try {
      emit(AuthLoading());
      // Simulation d'un appel API avec délai
      await Future.delayed(const Duration(milliseconds: 800));
      
      emit(InspectionDataLoaded({
        "status": "Approved",
        "batchId": "#FSH-99283",
        "fisherName": "Captain Elias",
        "fishType": "Sardin",
        "expiryDate": "Mar 21, 2026",
        "timeLeft": "01 Day, 23 hours restants",
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
        Uri.parse("$_baseUrl/api/profile"),
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

  // --- COMPLETE SETUP (MULTIPART) ---
  Future<void> submitSetup({
    required String token,
    required String fullName,
    required String nationalId,
    required String phone,
    required String email,
    required String boatName,
    required String registrationNumber,
    required String vesselType,
    required String homePort,
    required String licenseNumber,
    required String expiryDate,
    File? fishingLicense,
    File? boatRegistration,
  }) async {
    try {
      emit(SetupLoading());

      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/api/complete-setup"));
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      });

      request.fields['fullName'] = fullName;
      request.fields['nationalId'] = nationalId;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['boatName'] = boatName;
      request.fields['registrationNumber'] = registrationNumber;
      request.fields['vesselType'] = vesselType;
      request.fields['homePort'] = homePort;
      request.fields['licenseNumber'] = licenseNumber;
      request.fields['expiryDate'] = expiryDate;

      if (fishingLicense != null) {
        request.files.add(await http.MultipartFile.fromPath('fishingLicense', fishingLicense.path));
      }
      if (boatRegistration != null) {
        request.files.add(await http.MultipartFile.fromPath('boatRegistration', boatRegistration.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("Setup failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
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

  //Fill information of Vitirinaire
  Future<void> submitSetupVit({
    required String token,
    required String fullNameVit,
    required String nationalIdVit,
    required String phoneVit,
    required String emailVit,
    required String boatNameVit,
    required String registrationNumberVit,
    required String homePortVit,
    required String licenseNumberVit,
    required String expiryDateVit,
    File? fishingLicenseVit,
    File? boatRegistrationVit,
  }) async {
    try {
      emit(SetupLoading());

      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/api/complete-setup"));
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      });

      request.fields['fullNameVit'] = fullNameVit;
      request.fields['nationalIdVit'] = nationalIdVit;
      request.fields['phoneVit'] = phoneVit;
      request.fields['emailVit'] = emailVit;
      request.fields['boatNameVit'] = boatNameVit;
      request.fields['registrationNumberVit'] = registrationNumberVit;
      request.fields['homePortVit'] = homePortVit;
      request.fields['licenseNumberVit'] = licenseNumberVit;
      request.fields['expiryDateVit'] = expiryDateVit;

      if (fishingLicenseVit != null) {
        request.files.add(await http.MultipartFile.fromPath('fishingLicense', fishingLicenseVit.path));
      }
      if (boatRegistrationVit != null) {
        request.files.add(await http.MultipartFile.fromPath('boatRegistration', boatRegistrationVit.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SetupSuccess());
      } else {
        emit(AuthError("Setup failed: ${response.body}"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- EMAIL & CODE ---
  Future<void> sendEmail(String email) async {
    try {
      emit(AuthLoading());
      final response = await http.post(
        Uri.parse("$_baseUrl/api/send-email"),
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
        Uri.parse("$_baseUrl/api/verify-code"),
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
