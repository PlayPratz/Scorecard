import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static final TextStyle _base = GoogleFonts.ubuntu();

  static final TextTheme theme =
      GoogleFonts.ubuntuTextTheme(ThemeData.dark().textTheme);

  static final TextStyle standard = _base.merge(const TextStyle(
    fontSize: 12,
    color: Colors.white,
  ));
}
