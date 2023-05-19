import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static late SharedPreferences _prefs;

  // Constants
  static const kJwtTokenKey = 'jwt_token';

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set the JWT token value
  static Future<void> setJwtToken(String token) async {
    await _prefs.setString(kJwtTokenKey, token);
  }

  // Get the JWT token value
  static String? getJwtToken() {
    return _prefs.getString(kJwtTokenKey);
  }

  // Remove the JWT token value
  static Future<void> removeJwtToken() async {
    await _prefs.remove(kJwtTokenKey);
  }
}
