import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Utils {
  Utils._(); // Private constructor

  static const _uuid = Uuid();
  static String generateUniqueId() => _uuid.v1();

  static Future<dynamic> goToPage(Widget page, BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<dynamic> goToReplacementPage(
      Widget page, BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static Map<String, dynamic> castMap(Map<dynamic, dynamic> map) {
    for (final key in map.keys) {
      if (map[key] is Map) {
        map[key] = castMap(map[key]);
      } else if (map[key] is List) {
        if ((map[key] as List).any((element) => element is Map)) {
          map[key] = [for (final element in map[key]) castMap(element)];
        }
      }
    }
    return map.cast<String, dynamic>();
  }

  static double handleDivideByZero(num numerator, num denominator,
      {num fallback = 0}) {
    if (denominator == 0) {
      return fallback.toDouble();
    }
    return numerator / denominator;
  }
}
