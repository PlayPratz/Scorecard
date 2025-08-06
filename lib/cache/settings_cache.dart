class SettingsCache {
  SettingsCache._();
  static final _instance = SettingsCache._();

  factory SettingsCache() => _instance;

  bool showIds = false;
}
