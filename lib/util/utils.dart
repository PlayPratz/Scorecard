import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';

class Utils {
  Utils._(); // Private constructor

  static Future<dynamic> goToPage(Widget page, BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static List<Player> getAllPlayers() {
    return [..._playerList];
  }
}

List<Player> _playerList = [
  Player.withPhoto(
    id: 1,
    name: "Pratik",
    imagePath: "assets/images/pratik.png",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player.withPhoto(
    id: 2,
    name: "Chaitanya",
    imagePath: "assets/images/chaitanya.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player.withPhoto(
    id: 3,
    name: "Rutash",
    imagePath: "assets/images/rutash.png",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.fast,
  ),
  Player.withPhoto(
    id: 4,
    name: "Calden",
    imagePath: "assets/images/calden.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player.withPhoto(
    id: 5,
    name: "Noah",
    imagePath: "assets/images/noah.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player.withPhoto(
    id: 6,
    name: "Roshan",
    imagePath: "assets/images/roshan.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
];
