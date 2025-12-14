import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static late SharedPreferences _prefs;

  /// ✅ Panggil ini dulu di main() sebelum runApp()
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------ KEY NAMES ------------------
  static const String _keyToken = 'token';
  static const String _keyUserName = 'userName';
  static const String _keyUserId = 'userId';
  static const String _keyUserPhoto = 'userPhoto';
  static const String _keyLocationName = 'locationName';
  static const String _keyLatitude = 'latitude';
  static const String _keyLongitude = 'longitude';
  static const String _keyMaxDistance = 'maxDistance';
  static const String _keyComId = 'comid';
  static const String _keyCompanyName = 'companyName';
  static const String _keyIsPeternakan = 'isPeternakan';

  // ------------------ SETTERS ------------------
  static Future setToken(String value) async =>
      await _prefs.setString(_keyToken, value);

  static Future setUserName(String value) async =>
      await _prefs.setString(_keyUserName, value);

  static Future setUserId(String value) async =>
      await _prefs.setString(_keyUserId, value);

  static Future setUserPhoto(String value) async =>
      await _prefs.setString(_keyUserPhoto, value);

  static Future setLocationName(String value) async =>
      await _prefs.setString(_keyLocationName, value);

  static Future setLatitude(String value) async =>
      await _prefs.setString(_keyLatitude, value);

  static Future setLongitude(String value) async =>
      await _prefs.setString(_keyLongitude, value);

  static Future setMaxDistance(String value) async =>
      await _prefs.setString(_keyMaxDistance, value);

  static Future setComId(String value) async =>
      await _prefs.setString(_keyComId, value);

  static Future setCompanyName(String value) async =>
      await _prefs.setString(_keyCompanyName, value);

  static Future setIsPeternakan(String value) async =>
      await _prefs.setString(_keyIsPeternakan, value);

  // ------------------ GETTERS ------------------
  static String? getToken() => _prefs.getString(_keyToken);

  static String? getUserName() => _prefs.getString(_keyUserName);

  static String? getUserId() => _prefs.getString(_keyUserId);

  static String? getUserPhoto() => _prefs.getString(_keyUserPhoto);

  static String? getLocationName() => _prefs.getString(_keyLocationName);

  static String? getLatitude() => _prefs.getString(_keyLatitude);

  static String? getLongitude() => _prefs.getString(_keyLongitude);

  static String? getMaxDistance() => _prefs.getString(_keyMaxDistance);

  static String? getComId() => _prefs.getString(_keyComId);

  static String? getCompanyName() => _prefs.getString(_keyCompanyName);

  static String? getIsPeternakan() => _prefs.getString(_keyIsPeternakan);

  // ------------------ CLEAR DATA ------------------
  static Future clearAll() async => await _prefs.clear();

  static Future remove(String key) async => await _prefs.remove(key);
}
