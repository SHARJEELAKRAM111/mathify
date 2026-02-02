import 'package:flutter/material.dart';

import '../persistence/prefs_keys.dart';
import '../persistence/prefs_service.dart';
import 'app_themes.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    _load();
  }

  final PrefsService _prefs;

  AppThemeId _themeId = AppThemeId.classicLight;

  AppThemeId get themeId => _themeId;
  ThemeData get themeData => AppThemes.byId(_themeId);

  void _load() {
    final stored = _prefs.getInt(PrefKeys.themeId, defaultValue: AppThemeId.classicLight.index);
    _themeId = AppThemeId.values[stored.clamp(0, AppThemeId.values.length - 1)];
    notifyListeners();
  }

  Future<void> setTheme(AppThemeId id) async {
    if (_themeId == id) return;
    _themeId = id;
    await _prefs.setInt(PrefKeys.themeId, id.index);
    notifyListeners();
  }
}
