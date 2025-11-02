import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Service (Frontend Only)
/// Uses local storage (SharedPreferences) for session management
/// Backend/Firebase integration will be added after frontend completion
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<void> logout() async {
    await setLoggedIn(false);
  }
}
