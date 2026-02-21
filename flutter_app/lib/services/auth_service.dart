import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConstants.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  final ApiService _api = ApiService();

  // ─── Google Sign-In (Mobile) ───
  Future<UserModel?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('No ID token received from Google');

      final data = await _api.googleLogin(idToken);
      await _saveTokens(data);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUser(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Restore session ───
  Future<UserModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(AppConstants.kAccessToken);
    final userData = prefs.getString(AppConstants.kUserData);

    if (accessToken == null || userData == null) return null;

    try {
      final user = UserModel.fromJson(
        jsonDecode(userData) as Map<String, dynamic>,
      );
      // Refresh profile from server
      final fresh = await _api.getProfile();
      await _saveUser(fresh);
      return fresh;
    } catch (_) {
      return null;
    }
  }

  // ─── Logout ───
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString(AppConstants.kRefreshToken);
      if (refresh != null) await _api.logout(refresh);
    } catch (_) {}

    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.kAccessToken);
    await prefs.remove(AppConstants.kRefreshToken);
    await prefs.remove(AppConstants.kUserData);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kAccessToken, data['access'] ?? '');
    await prefs.setString(AppConstants.kRefreshToken, data['refresh'] ?? '');
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kUserData, jsonEncode(user.toJson()));
  }
}
