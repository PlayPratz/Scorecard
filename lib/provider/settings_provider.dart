import 'package:flutter/material.dart';
import 'package:scorecard/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Defaults
  ScorecardTheme _theme = ScorecardTheme.light;
  ScorecardTheme get theme => _theme;
  set theme(ScorecardTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  bool showIds = false;
}
