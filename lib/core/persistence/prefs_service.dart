import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();
  static final PrefsService instance = PrefsService._();

  SharedPreferences? _prefs;

  Future<void> ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _readyPrefs {
    final p = _prefs;
    if (p == null) {
      throw StateError('PrefsService not initialized. Call ensureReady() first.');
    }
    return p;
  }

  int getInt(String key, {int defaultValue = 0}) => _readyPrefs.getInt(key) ?? defaultValue;
  bool getBool(String key, {bool defaultValue = false}) => _readyPrefs.getBool(key) ?? defaultValue;
  String getString(String key, {String defaultValue = ''}) => _readyPrefs.getString(key) ?? defaultValue;
  List<String> getStringList(String key) => _readyPrefs.getStringList(key) ?? <String>[];

  Future<void> setInt(String key, int value) => _readyPrefs.setInt(key, value);
  Future<void> setBool(String key, bool value) => _readyPrefs.setBool(key, value);
  Future<void> setString(String key, String value) => _readyPrefs.setString(key, value);
  Future<void> setStringList(String key, List<String> value) => _readyPrefs.setStringList(key, value);
  Future<void> remove(String key) => _readyPrefs.remove(key);
}
