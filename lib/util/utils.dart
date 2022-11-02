import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cricket_match.dart';
import '../models/team.dart';

class Utils {
  Utils._(); // Private constructor

  static const _uuid = Uuid();

  static String generateUniqueId() => _uuid.v1();

  static Future<dynamic> goToPage(Widget page, BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static Future<dynamic> goToReplacementPage(
      Widget page, BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static List<CricketMatch> getAllMatches() {
    return [..._matchList];
  }

  static void saveMatch(CricketMatch match) {
    // Check whether match exists in storage
    // If yes, update
    // Else, add to list
    _matchList.remove(match);
    _matchList.insert(0, match);
  }
}

final List<CricketMatch> _matchList = [];
