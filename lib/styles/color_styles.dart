import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';

class ColorStyles {
  ColorStyles._();

  static const background = Color(0xFF121212);
  static const elevated = Color(0xFF242424);
  // static const card = Color(0xFF000041);
  static const card = Color(0xFF1E1E1E);
  // static const selected = Color(0xFF0a84ff);
  static const selected = Colors.blue;
  static const text = Colors.white;
  static const remove = Colors.redAccent;

  // Balls
  static const Color ballFour = Colors.indigoAccent;
  static const Color ballSix = Colors.pink;
  static const Color wicket = Colors.red;
  static const Color ballNoBall = Colors.yellowAccent;
  static const Color ballWide = Colors.white;
  static const Color ballEvent = Colors.blueGrey;

  // static const highlight = Color(0xFFFF8000);
  static const highlight = Colors.greenAccent;
  static const online = Color(0xFF30D158);

  static const List<Color> teamColors = [
    Colors.blue,
    Colors.deepOrange,
    Colors.amber,
    Colors.green,
    Colors.deepPurple,
    Colors.cyan,
    Colors.brown,
    Colors.purple,
    Colors.lime,
  ];

  static Color getBowlingExtraColour(BowlingExtra bowlingExtra) {
    if (bowlingExtra == BowlingExtra.noBall) {
      return ballNoBall;
    }
    return ballWide;
  }
}
