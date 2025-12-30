import 'package:scorecard/provider/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final _preferences = SharedPreferencesAsync();
  final SettingsProvider provider;

  SettingsService(this.provider);

  Future<void> initialize() async {
    provider.theme = await _getThemeFromPref();
    provider.showHandles = await _getShowIdsFromPref();
  }

  Future<void> toggleTheme() async {
    if (provider.theme == ScorecardTheme.light) {
      provider.theme = ScorecardTheme.dark;
    } else {
      provider.theme = ScorecardTheme.light;
    }

    final intTheme = switch (provider.theme) {
      ScorecardTheme.light => 0,
      ScorecardTheme.dark => 1,
    };
    await _preferences.setInt("theme", intTheme);
  }

  ScorecardTheme getTheme() {
    return provider.theme;
  }

  Future<ScorecardTheme> _getThemeFromPref() async {
    final intTheme = await _preferences.getInt("theme");
    final theme = intTheme == 1 ? ScorecardTheme.dark : ScorecardTheme.light;
    return theme;
  }

  Future<void> toggleShowIds() async {
    provider.showHandles = !provider.showHandles;
    await _preferences.setBool("showHandles", provider.showHandles);
  }

  bool getShowHandles() {
    return provider.showHandles;
  }

  Future<bool> _getShowIdsFromPref() async {
    final showIds = await _preferences.getBool("showHandles");
    return showIds ?? false;
  }
}

enum ScorecardTheme {
  light,
  dark,
}
