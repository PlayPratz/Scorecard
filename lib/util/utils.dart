import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
}
