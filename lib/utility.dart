

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  // Logger ---------------------------------------------------------
  final logger = Logger(
      printer: PrettyPrinter(
    methodCount: 1,
    colors: true,
    printEmojis: true,
    printTime: false,
  ));

  // Test Logger
  void testLogger() {
    logger.t('Verbose log');
    logger.d('Debug log');
    logger.i('Info log');
    logger.w('Warning log');
    logger.e('Error log');
    logger.f('What a terrible failure log');
  }
  // ----------------------------------------------------------------

  // Check Network Connection ----------------------------------------
  // Check Network Connection
  static Future<String> checkNetwork() async {
    var checkNetwork = await Connectivity().checkConnectivity();
    if (checkNetwork.contains(ConnectivityResult.none)) {
      return '';
    } else if (checkNetwork.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    } else if (checkNetwork.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    }

    return '';
  }
  // ----------------------------------------------------------------

  // Shared Preferences ----------------------------------------------
  static SharedPreferences? _preferences;
  static Future initSharedPrefs() async =>
      _preferences = await SharedPreferences.getInstance();

  // Get Shared Preferences
  static dynamic getSharedPreference(String key) {
    if (_preferences == null) return null;
    return _preferences!.get(key);
  }

  // Set Shared Preferences
  static Future<bool> setSharedPreference(String key, dynamic value) async {
    if (_preferences == null) return false;
    if (value is String) return await _preferences!.setString(key, value);
    if (value is int) return await _preferences!.setInt(key, value);
    if (value is bool) return await _preferences!.setBool(key, value);
    if (value is double) return await _preferences!.setDouble(key, value);
    return false;
  }

  // Remove Shared Preferences
  static Future<bool> removeSharedPreference(String key) async {
    if (_preferences == null) return false;
    return await _preferences!.remove(key);
  }

  // Clear Shared Preferences
  static Future<bool> clearSharedPreference() async {
    if (_preferences == null) return false;
    return await _preferences!.clear();
  }

  // Check Shared Preferences
  static Future<bool> checkSharedPreference(String key) async {
    if (_preferences == null) return false;
    return _preferences!.containsKey(key);
  }
  // ----------------------------------------------------------------

}